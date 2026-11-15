// Supabase Edge Function (Deno). Deploy with JWT verification enabled.
// Required secret: OPENAI_API_KEY. Never put it in the Flutter application.
// Before production: enforce per-user quotas in a persistent database or gateway,
// set spending limits, and obtain privacy/legal review of provider data handling.
Deno.serve(async (req) => {
  const json = (status: number, data: Record<string, unknown>) => new Response(JSON.stringify(data), {
    status, headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
  if (req.method !== 'POST') return json(405, { error: 'Yalnızca POST desteklenir.' });
  const auth = req.headers.get('Authorization') ?? '';
  const token = auth.startsWith('Bearer ') ? auth.slice(7) : '';
  if (!token) return json(401, { error: 'Giriş yapmanız gerekiyor.' });
  const url = Deno.env.get('SUPABASE_URL');
  const anon = Deno.env.get('SUPABASE_ANON_KEY');
  const apiKey = Deno.env.get('OPENAI_API_KEY');
  if (!url || !anon || !apiKey) return json(503, { error: 'AI servisi henüz yapılandırılmadı.' });
  // Verify identity with Auth server; never trust a client-supplied user id.
  const userResult = await fetch(`${url}/auth/v1/user`, { headers: {
    apikey: anon, Authorization: `Bearer ${token}`,
  } });
  if (!userResult.ok) return json(401, { error: 'Oturum geçersiz.' });
  let body: unknown;
  try { body = await req.json(); } catch { return json(400, { error: 'Geçersiz istek.' }); }
  const question = typeof body === 'object' && body !== null && 'question' in body
    ? (body as { question?: unknown }).question : undefined;
  if (typeof question !== 'string' || question.trim().length < 3 || question.length > 1200) {
    return json(400, { error: 'Soru 3–1200 karakter olmalıdır.' });
  }
  try {
    const result = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${apiKey}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: Deno.env.get('OPENAI_MODEL') ?? 'gpt-4.1-mini',
        max_output_tokens: 450,
        store: false,
        instructions: 'Türkçe, kısa ve anlaşılır yanıt ver. Anne, bebek, gebelik ve ev yaşamında genel eğitim amaçlı bilgi sun. Tanı, ilaç dozu, tedavi kararı verme. Acil belirtilerde acil sağlık hizmetine yönlendir. Bilmediğin bilgiyi uydurma. Kullanıcıya kişisel verilerini paylaşmamasını hatırlat.',
        input: question.trim(),
      }),
    });
    if (!result.ok) return json(502, { error: 'AI sağlayıcısına ulaşılamadı.' });
    const payload = await result.json();
    const answer = (payload.output ?? []).flatMap((item: { content?: { type?: string; text?: string }[] }) => item.content ?? [])
      .filter((item: { type?: string }) => item.type === 'output_text')
      .map((item: { text?: string }) => item.text ?? '').join('\n').trim();
    if (!answer) return json(502, { error: 'AI yanıtı oluşturulamadı.' });
    return json(200, { answer });
  } catch {
    return json(502, { error: 'AI hizmeti geçici olarak kullanılamıyor.' });
  }
});
