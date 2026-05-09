<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Sora', sans-serif;
            background: #eef2f7;
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
        }
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
        .card {
            display: flex; width: 780px; min-height: 460px;
            background: #fff; border-radius: 24px; overflow: hidden;
            box-shadow: 0 24px 64px rgba(0,0,0,0.12);
            animation: fadeUp 0.5s ease both;
        }
        @keyframes fadeUp {
            from { opacity:0; transform:translateY(28px); }
            to   { opacity:1; transform:translateY(0); }
        }
        .left {
            flex: 1; padding: 64px 52px;
            display: flex; flex-direction: column; justify-content: center;
        }
        .left h1 { font-size: 28px; font-weight: 700; color: #0f172a; margin-bottom: 8px; }
        .left .sub { font-size: 13.5px; color: #64748b; margin-bottom: 36px; line-height: 1.6; }
        .field {
            display: flex; align-items: center; gap: 12px;
            background: #f1f5f9; border: 1.5px solid transparent;
            border-radius: 14px; padding: 0 18px; height: 54px;
            transition: all 0.2s; margin-bottom: 20px;
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
        .btn-primary {
            width: 100%; height: 52px;
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: #fff; border: none; border-radius: 14px;
            font-family: inherit; font-size: 15px; font-weight: 600;
            cursor: pointer; position: relative;
            box-shadow: 0 4px 16px rgba(59,130,246,0.35);
            transition: opacity 0.2s, transform 0.1s;
            margin-bottom: 20px;
        }
        .btn-primary:hover { opacity: 0.91; }
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
        .back-link { text-align: center; font-size: 13.5px; }
        .back-link a { color: #3b82f6; text-decoration: none; font-weight: 500; }
        .back-link a:hover { text-decoration: underline; }
        .success-state { display: none; text-align: center; }
        .check-circle {
            width: 68px; height: 68px; background: #dcfce7;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px;
            animation: popIn 0.4s cubic-bezier(.34,1.56,.64,1) both;
        }
        @keyframes popIn { from { transform: scale(0); } to { transform: scale(1); } }
        .success-state h3 { font-size: 20px; font-weight: 700; color: #166534; margin-bottom: 10px; }
        .success-state p  { font-size: 13.5px; color: #64748b; line-height: 1.7; margin-bottom: 20px; }
        .success-state a  { color: #3b82f6; text-decoration: none; font-weight: 500; font-size: 13.5px; }
        .right {
            width: 320px; background: #0f172a;
            border-radius: 20px; margin: 12px;
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            text-align: center; padding: 40px 28px;
            position: relative; overflow: hidden;
        }
        .circle { position: absolute; border-radius: 50%; background: rgba(255,255,255,0.07); }
        .c1 { width:200px; height:200px; top:-70px; right:-60px; animation: float1 8s ease-in-out infinite; }
        .c2 { width:170px; height:170px; bottom:-55px; left:-45px; animation: float2 10s ease-in-out infinite; }
        .c3 { width:100px; height:100px; bottom:100px; right:-15px; animation: float3 7s ease-in-out infinite; }
        .c4 { width:65px; height:65px; top:140px; left:20px; animation: float4 9s ease-in-out infinite; }
        @keyframes float1 { 0%,100%{transform:translate(0,0) scale(1);} 33%{transform:translate(-14px,20px) scale(1.07);} 66%{transform:translate(10px,-10px) scale(0.95);} }
        @keyframes float2 { 0%,100%{transform:translate(0,0) scale(1);} 40%{transform:translate(16px,-18px) scale(1.08);} 70%{transform:translate(-10px,12px) scale(0.93);} }
        @keyframes float3 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(-18px,-22px);} }
        @keyframes float4 { 0%,100%{transform:translate(0,0);} 50%{transform:translate(14px,16px);} }
        .right-content { position: relative; z-index: 1; }
        .right-icon {
            width: 80px; height: 80px;
            background: rgba(255,255,255,0.13); border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 24px;
            box-shadow: 0 0 0 14px rgba(255,255,255,0.04);
        }
        .right h2 { font-size: 22px; font-weight: 700; color: #fff; margin-bottom: 12px; }
        .right p  { font-size: 13px; color: #94a3b8; line-height: 1.7; }
    </style>
</head>
<body>

<div class="toast" id="toast"><span id="toastMsg"></span></div>

<div class="card">
    <div class="left">
        <div id="formState">
            <h1>Reset Password</h1>
            <p class="sub">Enter your email address and we'll send you reset instructions</p>
            <div class="field">
                <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                    <polyline points="22,6 12,13 2,6"/>
                </svg>
                <input type="email" id="emailInput" placeholder="Email Address">
            </div>
            <button class="btn-primary" id="resetBtn" onclick="handleReset()">
                <span class="btn-text">Send Reset Instructions</span>
                <div class="spinner"></div>
            </button>
            <p class="back-link"><a href="login.jsp">&#8592; Back to login</a></p>
        </div>
        <div class="success-state" id="successState">
            <div class="check-circle">
                <svg width="30" height="30" fill="none" stroke="#16a34a" stroke-width="2.5" viewBox="0 0 24 24">
                    <polyline points="20 6 9 17 4 12"/>
                </svg>
            </div>
            <h3>Check Your Email!</h3>
            <p>We've sent password reset instructions to your email. Please check your inbox and spam folder.</p>
            <a href="login.jsp">&#8592; Back to login</a>
        </div>
    </div>
    <div class="right">
        <div class="circle c1"></div>
        <div class="circle c2"></div>
        <div class="circle c3"></div>
        <div class="circle c4"></div>
        <div class="right-content">
            <div class="right-icon">
                <svg width="38" height="38" fill="none" stroke="#fff" stroke-width="1.5" viewBox="0 0 24 24">
                    <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/>
                </svg>
            </div>
            <h2>Don't Worry!</h2>
            <p>We'll help you reset your password quickly and securely.</p>
        </div>
    </div>
</div>

<script>
    // ✅ THE ROOT FIX: JSP scriptlet injects context path as a real JS variable
    // ${pageContext.request.contextPath} does NOT work inside <script> tags - it's not evaluated there
    var contextPath = '<%= request.getContextPath() %>';

    async function handleReset() {
        const email = document.getElementById('emailInput').value.trim();
        const btn   = document.getElementById('resetBtn');

        if (!email) { showToast('Please enter your email address.', 'error'); return; }
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            showToast('Please enter a valid email address.', 'error'); return;
        }

        btn.classList.add('loading');
        const form = new URLSearchParams();
        form.append('email', email);

        try {
            const res  = await fetch(contextPath + '/forgot-password', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: form.toString()
            });
            const text = await res.text();
            btn.classList.remove('loading');

            if (res.ok && text.trim() === 'success') {
                showToast('Reset instructions sent!', 'success');
                setTimeout(() => {
                    document.getElementById('formState').style.display = 'none';
                    document.getElementById('successState').style.display = 'block';
                }, 800);
            } else {
                showToast(text || 'Something went wrong.', 'error');
            }
        } catch(e) {
            btn.classList.remove('loading');
            showToast('Network error. Please try again.', 'error');
        }
    }

    function showToast(msg, type) {
        const t = document.getElementById('toast');
        document.getElementById('toastMsg').textContent = msg;
        t.className = 'toast ' + type + ' show';
        clearTimeout(t._t);
        t._t = setTimeout(() => t.classList.remove('show'), 3500);
    }

    document.getElementById('emailInput').addEventListener('keydown', e => {
        if (e.key === 'Enter') handleReset();
    });
</script>
</body>
</html>
