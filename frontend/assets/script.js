// ─── CONFIG ───────────────────────────────────────────────────────────────────
// Replace this with your actual API Gateway invoke URL after terraform apply
const API_URL = 'REPLACE_API_URL';

// ─── CONTACT FORM ─────────────────────────────────────────────────────────────
async function submitForm() {
  const email   = document.getElementById('email').value.trim();
  const query   = document.getElementById('query').value.trim();
  const name = document.getElementById('name').value.trim();
  const btn     = document.getElementById('submit-btn');
  const status  = document.getElementById('form-status');

  // Reset status
  status.className = 'form-status';
  status.textContent = '';

  // Basic validation
  if (!email || !query) {
    status.className = 'form-status error';
    status.textContent = 'Please fill in all fields.';
    return;
  }

  // Loading state
  btn.disabled = true;
  btn.textContent = 'Sending...';

  try {
    const response = await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, name, query }),
    });

    if (response.ok) {
      status.className = 'form-status success';
      status.textContent = 'Message sent — I\'ll be in touch soon.';
      document.getElementById('contact-form').reset();
    } else {
      throw new Error(`Server responded with ${response.status}`);
    }
  } catch (err) {
    status.className = 'form-status error';
    status.textContent = 'Something went wrong. Please try again or reach out via LinkedIn.';
    console.error(err);
  } finally {
    btn.disabled = false;
    btn.textContent = 'Send Message';
  }
}