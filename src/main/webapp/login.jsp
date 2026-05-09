<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sign In</title>
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700&display=swap" rel="stylesheet">
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Sora', sans-serif;
      background: #eef2f7;
      min-height: 100vh;
      display: flex; align-items: center; justify-content: center;
    }

    /* TOAST */
    .toast {
      position: fixed; top: 24px; left: 50%;
      transform: translateX(-50%) translateY(-90px);
      padding: 13px 22px; border-radius: 12px;
      font-size: 14px; font-weight: 500;
      box-shadow: 0 8px 32px rgba(0,0,0,0.18);
      z-index: 9999;
      transition: transform 0.45s cubic-bezier(.34,1.56,.64,1);
      display: flex; align-items: center; gap: 9px;
      color: #fff; white-space: nowrap;
    }
    .toast.show { transform: translateX(-50%) translateY(0); }
    .toast.success { background: #16a34a; }
    .toast.error   { background: #dc2626; }
    .toast.info    { background: #2563eb; }

    /* CARD */
    .card {
      display: flex; width: 880px; min-height: 540px;
      background: #fff; border-radius: 24px; overflow: hidden;
      box-shadow: 0 24px 64px rgba(0,0,0,0.12);
      animation: fadeUp 0.5s ease both;
    }
    @keyframes fadeUp {
      from { opacity:0; transform:translateY(28px); }
      to   { opacity:1; transform:translateY(0); }
    }

    /* LEFT */
    .left {
      flex: 1; padding: 56px 52px;
      display: flex; flex-direction: column; justify-content: center;
    }
    .left h1 { font-size: 30px; font-weight: 700; color: #0f172a; margin-bottom: 8px; }
    .left .sub { font-size: 13.5px; color: #64748b; margin-bottom: 38px; }

    .field {
      display: flex; align-items: center; gap: 12px;
      background: #f1f5f9; border: 1.5px solid transparent;
      border-radius: 14px; padding: 0 18px; height: 54px;
      transition: all 0.2s; margin-bottom: 14px;
    }
    .field:focus-within {
      border-color: #3b82f6; background: #fff;
      box-shadow: 0 0 0 4px rgba(59,130,246,0.1);
    }
    .field svg { color: #94a3b8; flex-shrink: 0; }
    .field input {
      flex: 1; border: none; background: transparent;
      outline: none; font-family: inherit; font-size: 14px; color: #0f172a;
    }
    .field input::placeholder { color: #94a3b8; }

    .forgot-row { text-align: right; margin-bottom: 22px; }
    .forgot-row a { font-size: 13px; color: #3b82f6; text-decoration: none; font-weight: 500; }
    .forgot-row a:hover { text-decoration: underline; }

    .btn-primary {
      width: 100%; height: 52px;
      background: linear-gradient(135deg, #3b82f6, #2563eb);
      color: #fff; border: none; border-radius: 14px;
      font-family: inherit; font-size: 15px; font-weight: 600;
      cursor: pointer; position: relative;
      box-shadow: 0 4px 16px rgba(59,130,246,0.35);
      transition: opacity 0.2s, transform 0.1s, box-shadow 0.2s;
    }
    .btn-primary:hover { opacity: 0.91; box-shadow: 0 6px 20px rgba(59,130,246,0.45); }
    .btn-primary:active { transform: scale(0.98); }
    .spinner {
      display: none; width: 20px; height: 20px;
      border: 2.5px solid rgba(255,255,255,0.3);
      border-top-color: #fff; border-radius: 50%;
      animation: spin 0.7s linear infinite;
      position: absolute; top: 50%; left: 50%;
      transform: translate(-50%,-50%);
    }
    @keyframes spin { to { transform: translate(-50%,-50%) rotate(360deg); } }
    .btn-primary.loading .btn-text { visibility: hidden; }
    .btn-primary.loading .spinner { display: block; }

    .divider {
      display: flex; align-items: center; gap: 12px;
      margin: 22px 0; color: #94a3b8; font-size: 13px;
    }
    .divider::before, .divider::after { content:''; flex:1; height:1px; background:#e2e8f0; }

    .social-row { display: flex; gap: 12px; margin-bottom: 26px; }
    .social-btn {
      flex: 1; height: 48px;
      border: 1.5px solid #e2e8f0; border-radius: 12px;
      background: #fff; cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      text-decoration: none;
      transition: border-color 0.2s, background 0.2s, transform 0.15s, box-shadow 0.2s;
    }
    .social-btn:hover {
      border-color: #3b82f6; background: #f0f7ff;
      transform: translateY(-3px);
      box-shadow: 0 6px 14px rgba(59,130,246,0.15);
    }
    .social-btn:active { transform: translateY(0); }

    .register-link { text-align: center; font-size: 13.5px; color: #64748b; }
    .register-link a { color: #3b82f6; font-weight: 600; text-decoration: none; }
    .register-link a:hover { text-decoration: underline; }

    /* RIGHT */
    .right {
      width: 340px; background: #0f172a;
      border-radius: 20px; margin: 12px;
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      text-align: center; padding: 40px 32px;
      position: relative; overflow: hidden;
    }
    .circle {
      position: absolute; border-radius: 50%;
      background: rgba(255,255,255,0.07);
    }
    .c1 { width:220px; height:220px; top:-80px; right:-70px; animation: float1 8s ease-in-out infinite; }
    .c2 { width:180px; height:180px; bottom:-60px; left:-50px; animation: float2 10s ease-in-out infinite; }
    .c3 { width:110px; height:110px; bottom:90px; right:-20px; animation: float3 7s ease-in-out infinite; }
    .c4 { width:70px;  height:70px;  top:130px; left:24px; animation: float4 9s ease-in-out infinite; }

    @keyframes float1 {
      0%,100% { transform: translate(0,0) scale(1); }
      33%      { transform: translate(-14px,20px) scale(1.07); }
      66%      { transform: translate(10px,-10px) scale(0.95); }
    }
    @keyframes float2 {
      0%,100% { transform: translate(0,0) scale(1); }
      40%      { transform: translate(16px,-18px) scale(1.08); }
      70%      { transform: translate(-10px,12px) scale(0.93); }
    }
    @keyframes float3 {
      0%,100% { transform: translate(0,0); }
      50%      { transform: translate(-18px,-22px); }
    }
    @keyframes float4 {
      0%,100% { transform: translate(0,0); }
      50%      { transform: translate(14px,16px); }
    }

    .right-content { position: relative; z-index: 1; }
    .right-icon {
      width: 76px; height: 76px;
      background: rgba(255,255,255,0.13); border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto 24px;
      box-shadow: 0 0 0 14px rgba(255,255,255,0.04);
    }
    .right h2 { font-size: 23px; font-weight: 700; color: #fff; margin-bottom: 12px; }
    .right p  { font-size: 13.5px; color: #94a3b8; line-height: 1.7; }
  </style>
</head>
<body>

<div class="toast" id="toast">
  <span id="toastMsg"></span>
</div>

<div class="card">
  <div class="left">
    <h1>Welcome Back</h1>
    <p class="sub">Sign in to your account to continue your journey</p>

    <div class="field">
      <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
        <polyline points="22,6 12,13 2,6"/>
      </svg>
      <input type="email" id="emailInput" placeholder="Email Address">
    </div>

    <div class="field">
      <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
      </svg>
      <input type="password" id="passwordInput" placeholder="Password">
    </div>

    <div class="forgot-row"><a href="forgot-password.jsp">Forgot Password?</a></div>

    <button class="btn-primary" id="loginBtn" onclick="handleLogin()">
      <span class="btn-text">Sign In</span>
      <div class="spinner"></div>
    </button>

    <div class="divider">Or continue with</div>

    <div class="social-row">
      <a class="social-btn" href="https://accounts.google.com" target="_blank" title="Google">
        <svg width="20" height="20" viewBox="0 0 48 48">
          <path fill="#EA4335" d="M24 9.5c3.5 0 6.6 1.2 9 3.2l6.7-6.7C35.7 2.4 30.2 0 24 0 14.8 0 6.9 5.4 3 13.3l7.8 6C12.7 13.2 17.9 9.5 24 9.5z"/>
          <path fill="#4285F4" d="M46.5 24.5c0-1.6-.1-3.1-.4-4.5H24v8.5h12.7c-.6 3-2.3 5.5-4.8 7.2l7.5 5.8c4.4-4.1 6.9-10.1 6.9-17z"/>
          <path fill="#FBBC05" d="M10.8 28.7A14.5 14.5 0 0 1 9.5 24c0-1.6.3-3.2.8-4.7L2.5 13.3A23.9 23.9 0 0 0 0 24c0 3.8.9 7.4 2.5 10.6l8.3-5.9z"/>
          <path fill="#34A853" d="M24 48c6.2 0 11.4-2 15.2-5.5l-7.5-5.8c-2.1 1.4-4.7 2.2-7.7 2.2-6.1 0-11.3-3.7-13.2-9.2l-8.3 5.9C6.9 42.6 14.8 48 24 48z"/>
        </svg>
      </a>
      <a class="social-btn" href="https://www.facebook.com/login" target="_blank" title="Facebook">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="#1877F2">
          <path d="M24 12.073C24 5.405 18.627 0 12 0S0 5.405 0 12.073C0 18.1 4.388 23.094 10.125 24v-8.437H7.078v-3.49h3.047V9.413c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.234 2.686.234v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.49h-2.796V24C19.612 23.094 24 18.1 24 12.073z"/>
        </svg>
      </a>
      <a class="social-btn" href="https://twitter.com/login" target="_blank" title="Twitter">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="#1DA1F2">
          <path d="M23.954 4.569a10 10 0 0 1-2.825.775 4.958 4.958 0 0 0 2.163-2.723 9.99 9.99 0 0 1-3.127 1.195 4.92 4.92 0 0 0-8.384 4.482C7.691 8.094 4.066 6.13 1.64 3.161a4.822 4.822 0 0 0-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 0 1-2.228-.616v.061a4.923 4.923 0 0 0 3.946 4.827 4.996 4.996 0 0 1-2.212.085 4.937 4.937 0 0 0 4.604 3.417 9.868 9.868 0 0 1-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 0 0 7.557 2.209c9.054 0 13.999-7.496 13.999-13.986 0-.209 0-.42-.015-.63a9.936 9.936 0 0 0 2.46-2.548l-.047-.02z"/>
        </svg>
      </a>
    </div>

    <p class="register-link">Don't have an account? <a href="register.jsp">Create one</a></p>
  </div>

  <div class="right">
    <div class="circle c1"></div>
    <div class="circle c2"></div>
    <div class="circle c3"></div>
    <div class="circle c4"></div>
    <div class="right-content">
      <div class="right-icon">
        <svg width="38" height="38" fill="none" stroke="#fff" stroke-width="1.5" viewBox="0 0 24 24">
          <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
          <circle cx="12" cy="7" r="4"/>
        </svg>
      </div>
      <h2>Welcome Back!</h2>
      <p>Sign in to access your account and pick up right where you left off.</p>
    </div>
  </div>
</div>

<script>
  // Show success toast if redirected from register page
  const params = new URLSearchParams(window.location.search);
  if (params.get('registered') === 'true') {
    showToast('🎉 Account created! Please sign in.', 'success');
  }

  async function handleLogin() {
    const email    = document.getElementById('emailInput').value.trim();
    const password = document.getElementById('passwordInput').value;
    const btn      = document.getElementById('loginBtn');

    if (!email || !password) {
      showToast('⚠️ Please enter your email and password.', 'error');
      return;
    }

    btn.classList.add('loading');

    const form = new URLSearchParams();
    form.append('email', email);
    form.append('password', password);

    try {
      const res = await fetch('login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: form.toString(),
        redirect: 'manual'
      });

      // Servlet redirects to dashboard.jsp on success (status 0 = opaque redirect)
      if (res.status === 0 || res.type === 'opaqueredirect') {
        showToast('✅ Login successful! Redirecting…', 'success');
        setTimeout(() => window.location.href = 'dashboard.jsp', 1200);
      } else if (res.ok) {
        showToast('✅ Login successful! Redirecting…', 'success');
        setTimeout(() => window.location.href = 'dashboard.jsp', 1200);
      } else {
        const msg = await res.text();
        showToast('❌ ' + (msg || 'Invalid email or password.'), 'error');
      }
    } catch (e) {
      showToast('❌ Network error. Please try again.', 'error');
    } finally {
      btn.classList.remove('loading');
    }
  }

  function showToast(msg, type) {
    const t = document.getElementById('toast');
    document.getElementById('toastMsg').textContent = msg;
    t.className = 'toast ' + type + ' show';
    clearTimeout(t._t);
    t._t = setTimeout(() => t.classList.remove('show'), 3500);
  }

  document.addEventListener('keydown', e => { if (e.key === 'Enter') handleLogin(); });
</script>
</body>
</html>
