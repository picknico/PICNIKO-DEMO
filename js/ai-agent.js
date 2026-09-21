import {getDb, currentUser} from './db.js';

const endpoint = () => window.PICNIKO_CONFIG?.AI_AGENT_ENDPOINT || '';

export async function askPicnikoAI(message, context = {}) {
  const text = String(message || '').trim();
  if (!text) return {reply: ''};

  const url = endpoint();
  if (!url) return {reply: aiDemoReply(text), mode: 'demo'};

  try {
    const user = await currentUser();
    const response = await fetch(url, {
      method: 'POST',
      headers: {'Content-Type':'application/json'},
      body: JSON.stringify({
        message: text,
        user_id: user?.id || null,
        context
      })
    });
    if (!response.ok) throw new Error(`AI endpoint ${response.status}`);
    const data = await response.json();
    return {reply: String(data.reply || data.message || ''), mode: 'live'};
  } catch (error) {
    console.warn('PICNIKO AI fallback:', error);
    return {reply: aiDemoReply(text), mode: 'fallback'};
  }
}

export function aiDemoReply(text) {
  const q = text.toLowerCase();
  if (q.includes('mulshi') || q.includes('फिर') || q.includes('ठिकाण')) {
    return 'मी Nearby module मधून तुमच्या परिसरातील places, hotels, restaurants आणि experiences शोधण्याच्या flow ला जोडला जाऊ शकतो. Live search साठी AI endpoint + database connection activate करायचा आहे.';
  }
  if (q.includes('reward') || q.includes('qr') || q.includes('bottle')) {
    return 'Mulshi Fresh मध्ये QR scan → server verification → duplicate/fraud check → eligible reward → PICNIKO wallet हा सुरक्षित flow ठेवला आहे.';
  }
  if (q.includes('shop') || q.includes('product') || q.includes('खरेदी')) {
    return 'Shop मध्ये product, seller, offer आणि qualified order flow तपासून AI तुम्हाला योग्य पर्याय दाखवू शकतो. व्यवहार करण्यापूर्वी seller/product details verify करा.';
  }
  if (q.includes('property') || q.includes('real estate') || q.includes('घर')) {
    return 'Professional module मधून Agent, Owner आणि Builder listings शोधण्याचा flow जोडता येईल. AI तुमच्या budget, location आणि property type नुसार filtering करू शकतो.';
  }
  return 'मी PICNIKO मधील योग्य service शोधून देण्यासाठी तयार आहे. सध्या demo mode आहे; सुरक्षित server-side AI connection जोडल्यावर live उत्तर आणि module actions सक्षम होतील.';
}
