<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="org.example.myproject.model.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userName    = user.getName();
    String userEmail   = user.getEmail();
    String userInitial = (userName != null && !userName.isEmpty())
            ? String.valueOf(userName.charAt(0)).toUpperCase() : "U";
%>
<%!
    private String getGreeting() {
        int hour = java.time.LocalTime.now().getHour();
        if (hour < 12) return "Morning";
        if (hour < 17) return "Afternoon";
        return "Evening";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SpendWise – Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root{
            --bg:#0f1117;--surface:#1a1d27;--surface2:#22263a;
            --border:rgba(255,255,255,0.07);--text:#f1f5f9;--muted:#64748b;
            --blue:#3b82f6;--blue-dark:#2563eb;
            --green:#22c55e;--red:#ef4444;--yellow:#f59e0b;--purple:#a855f7;
        }
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        body{font-family:'Sora',sans-serif;background:var(--bg);color:var(--text);min-height:100vh;display:flex}

        .sidebar{width:260px;min-height:100vh;background:var(--surface);border-right:1px solid var(--border);display:flex;flex-direction:column;padding:28px 20px;position:fixed;top:0;left:0;bottom:0;z-index:100}
        .logo{display:flex;align-items:center;gap:12px;margin-bottom:40px;padding:0 8px}
        .logo-icon{width:40px;height:40px;background:var(--blue);border-radius:12px;display:flex;align-items:center;justify-content:center}
        .logo span{font-size:17px;font-weight:700}
        .nav{flex:1}
        .nav-item{display:flex;align-items:center;gap:12px;padding:12px 14px;border-radius:12px;font-size:14px;font-weight:500;color:var(--muted);cursor:pointer;transition:all .2s;margin-bottom:4px;text-decoration:none}
        .nav-item:hover{background:var(--surface2);color:var(--text)}
        .nav-item.active{background:var(--blue);color:#fff}
        .sidebar-user{border-top:1px solid var(--border);padding-top:20px;margin-top:20px;display:flex;align-items:center;gap:12px}
        .user-avatar{width:40px;height:40px;border-radius:50%;flex-shrink:0;background:linear-gradient(135deg,var(--blue),var(--purple));display:flex;align-items:center;justify-content:center;font-size:15px;font-weight:700;color:#fff}
        .user-info{flex:1;min-width:0}
        .user-info .name{font-size:13px;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .user-info .email{font-size:11px;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .logout-btn{background:none;border:none;cursor:pointer;color:var(--muted);transition:color .2s;padding:4px;text-decoration:none;display:flex}
        .logout-btn:hover{color:var(--red)}

        .main{margin-left:260px;flex:1;padding:32px 36px;min-height:100vh}
        .top-bar{display:flex;align-items:center;justify-content:space-between;margin-bottom:32px}
        .top-bar h1{font-size:24px;font-weight:700}
        .top-bar .date{font-size:13px;color:var(--muted)}
        .add-btn{display:flex;align-items:center;gap:8px;background:var(--blue);color:#fff;border:none;border-radius:12px;padding:11px 20px;font-family:inherit;font-size:14px;font-weight:600;cursor:pointer;transition:opacity .2s,transform .1s;box-shadow:0 4px 16px rgba(59,130,246,.4)}
        .add-btn:hover{opacity:.9}
        .add-btn:active{transform:scale(.97)}

        .summary-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:20px;margin-bottom:32px}
        .summary-card{background:var(--surface);border-radius:18px;padding:24px;border:1px solid var(--border);transition:transform .2s}
        .summary-card:hover{transform:translateY(-2px)}
        .summary-card .label{font-size:12px;color:var(--muted);font-weight:500;text-transform:uppercase;letter-spacing:.05em;margin-bottom:10px}
        .summary-card .amount{font-size:30px;font-weight:800;margin-bottom:6px}
        .summary-card .sub{font-size:12px;color:var(--muted)}
        .summary-card .icon{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;margin-bottom:16px}
        .income-card .icon{background:rgba(34,197,94,.15)}.income-card .amount{color:var(--green)}
        .expense-card .icon{background:rgba(239,68,68,.15)}.expense-card .amount{color:var(--red)}
        .balance-card .icon{background:rgba(59,130,246,.15)}.balance-card .amount{color:var(--blue)}

        .content-grid{display:grid;grid-template-columns:1fr 360px;gap:24px}
        .panel{background:var(--surface);border-radius:18px;border:1px solid var(--border);overflow:hidden}
        .panel-header{display:flex;align-items:center;justify-content:space-between;padding:20px 24px;border-bottom:1px solid var(--border)}
        .panel-header h2{font-size:16px;font-weight:700}
        .filter-tabs{display:flex;gap:6px}
        .filter-tab{padding:6px 14px;border-radius:8px;font-size:12px;font-weight:600;cursor:pointer;border:none;font-family:inherit;background:var(--surface2);color:var(--muted);transition:all .2s}
        .filter-tab.active{background:var(--blue);color:#fff}

        .tx-list{padding:8px 0;max-height:440px;overflow-y:auto}
        .tx-list::-webkit-scrollbar{width:4px}
        .tx-list::-webkit-scrollbar-thumb{background:var(--border);border-radius:4px}
        .tx-item{display:flex;align-items:center;gap:14px;padding:14px 24px;transition:background .15s}
        .tx-item:hover{background:var(--surface2)}
        .tx-icon{width:42px;height:42px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0}
        .tx-info{flex:1;min-width:0}
        .tx-info .tx-name{font-size:14px;font-weight:600;margin-bottom:3px}
        .tx-info .tx-date{font-size:12px;color:var(--muted)}
        .tx-amount{font-size:15px;font-weight:700}
        .tx-amount.income{color:var(--green)}.tx-amount.expense{color:var(--red)}
        .tx-actions{display:flex;gap:4px;opacity:0;transition:opacity .2s}
        .tx-item:hover .tx-actions{opacity:1}
        .tx-btn{background:none;border:none;cursor:pointer;color:var(--muted);padding:6px;border-radius:8px;transition:all .2s}
        .tx-btn.edit:hover{background:rgba(59,130,246,.15);color:var(--blue)}
        .tx-btn.del:hover{background:rgba(239,68,68,.15);color:var(--red)}
        .empty-state{text-align:center;padding:60px 24px;color:var(--muted);font-size:14px}
        .empty-state .empty-icon{font-size:48px;margin-bottom:12px}

        .cat-list{padding:16px 24px}
        .cat-item{display:flex;align-items:center;gap:12px;margin-bottom:16px}
        .cat-item:last-child{margin-bottom:0}
        .cat-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0}
        .cat-name{font-size:13px;flex:1}
        .cat-bar-wrap{width:100px;height:6px;background:var(--surface2);border-radius:3px;overflow:hidden}
        .cat-bar{height:100%;border-radius:3px;transition:width .5s ease}
        .cat-amount{font-size:13px;font-weight:600;min-width:64px;text-align:right}

        .modal-overlay{position:fixed;inset:0;background:rgba(0,0,0,.7);display:none;align-items:center;justify-content:center;z-index:1000;backdrop-filter:blur(4px)}
        .modal-overlay.open{display:flex}
        .modal{background:var(--surface);border-radius:24px;padding:32px;width:460px;border:1px solid var(--border);animation:modalIn .3s cubic-bezier(.34,1.56,.64,1) both}
        @keyframes modalIn{from{opacity:0;transform:scale(.9) translateY(20px)}to{opacity:1;transform:scale(1) translateY(0)}}
        .modal h2{font-size:20px;font-weight:700;margin-bottom:24px}
        .modal-field{margin-bottom:16px}
        .modal-field label{font-size:12px;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin-bottom:8px;display:block}
        .modal-field input,.modal-field select{width:100%;height:48px;background:var(--surface2);border:1.5px solid var(--border);border-radius:12px;color:var(--text);font-family:inherit;font-size:14px;padding:0 16px;outline:none;transition:border-color .2s}
        .modal-field input:focus,.modal-field select:focus{border-color:var(--blue)}
        .modal-field select option{background:var(--surface2)}
        .type-toggle{display:flex;gap:8px}
        .type-btn{flex:1;height:44px;border-radius:12px;border:1.5px solid var(--border);background:var(--surface2);color:var(--muted);font-family:inherit;font-size:14px;font-weight:600;cursor:pointer;transition:all .2s}
        .type-btn.active-income{background:rgba(34,197,94,.15);border-color:var(--green);color:var(--green)}
        .type-btn.active-expense{background:rgba(239,68,68,.15);border-color:var(--red);color:var(--red)}
        .modal-actions{display:flex;gap:12px;margin-top:24px}
        .btn-cancel{flex:1;height:48px;border-radius:12px;border:1.5px solid var(--border);background:transparent;color:var(--muted);font-family:inherit;font-size:14px;font-weight:600;cursor:pointer;transition:all .2s}
        .btn-cancel:hover{background:var(--surface2);color:var(--text)}
        .btn-save{flex:1;height:48px;border-radius:12px;border:none;background:var(--blue);color:#fff;font-family:inherit;font-size:14px;font-weight:600;cursor:pointer;transition:opacity .2s}
        .btn-save:hover{opacity:.9}

        .toast{position:fixed;top:24px;left:50%;transform:translateX(-50%) translateY(-90px);padding:13px 22px;border-radius:12px;font-size:14px;font-weight:500;box-shadow:0 8px 32px rgba(0,0,0,.4);z-index:9999;transition:transform .45s cubic-bezier(.34,1.56,.64,1);display:flex;align-items:center;gap:9px;color:#fff}
        .toast.show{transform:translateX(-50%) translateY(0)}
        .toast.success{background:#16a34a}.toast.error{background:#dc2626}

        .loader-overlay{position:fixed;inset:0;background:var(--bg);display:flex;align-items:center;justify-content:center;z-index:9998;transition:opacity .3s}
        .loader-overlay.hidden{opacity:0;pointer-events:none}
        .spinner-big{width:48px;height:48px;border:4px solid var(--surface2);border-top-color:var(--blue);border-radius:50%;animation:spin .8s linear infinite}
        @keyframes spin{to{transform:rotate(360deg)}}
        .fade-in{animation:fadeIn .3s ease both}
        @keyframes fadeIn{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
    </style>
</head>
<body>

<div class="loader-overlay" id="loaderOverlay"><div class="spinner-big"></div></div>
<div class="toast" id="toast"><span id="toastMsg"></span></div>

<!-- SIDEBAR -->
<aside class="sidebar">
    <div class="logo">
        <div class="logo-icon">
            <svg width="22" height="22" fill="none" stroke="#fff" stroke-width="2" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/>
            </svg>
        </div>
        <span>SpendWise</span>
    </div>
    <nav class="nav">
        <a class="nav-item active" href="#">
            <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
                <rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/>
            </svg>
            Dashboard
        </a>
        <a class="nav-item" href="#" onclick="openModal(null);return false;">
            <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10"/>
                <line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/>
            </svg>
            Add Transaction
        </a>
        <a class="nav-item" href="#">
            <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/>
            </svg>
            Analytics
        </a>
        <a class="nav-item" href="#">
            <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M20 7H4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/>
                <circle cx="12" cy="12" r="2"/>
            </svg>
            Wallet
        </a>
    </nav>
    <div class="sidebar-user">
        <div class="user-avatar"><%= userInitial %></div>
        <div class="user-info">
            <div class="name"><%= userName %></div>
            <div class="email"><%= userEmail %></div>
        </div>
        <a href="logout" class="logout-btn" title="Logout">
            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                <polyline points="16 17 21 12 16 7"/>
                <line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
        </a>
    </div>
</aside>

<!-- MAIN -->
<main class="main">
    <div class="top-bar">
        <div>
            <h1>Good <%= getGreeting() %>, <%= userName %>!</h1>
            <div class="date" id="currentDate"></div>
        </div>
        <button class="add-btn" onclick="openModal(null)">
            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
                <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            Add Transaction
        </button>
    </div>

    <div class="summary-grid">
        <div class="summary-card income-card">
            <div class="icon">
                <svg width="22" height="22" fill="none" stroke="#22c55e" stroke-width="2" viewBox="0 0 24 24">
                    <line x1="12" y1="19" x2="12" y2="5"/><polyline points="5 12 12 5 19 12"/>
                </svg>
            </div>
            <div class="label">Total Income</div>
            <div class="amount" id="totalIncome">$0.00</div>
            <div class="sub">All time</div>
        </div>
        <div class="summary-card expense-card">
            <div class="icon">
                <svg width="22" height="22" fill="none" stroke="#ef4444" stroke-width="2" viewBox="0 0 24 24">
                    <line x1="12" y1="5" x2="12" y2="19"/><polyline points="19 12 12 19 5 12"/>
                </svg>
            </div>
            <div class="label">Total Expenses</div>
            <div class="amount" id="totalExpenses">$0.00</div>
            <div class="sub">All time</div>
        </div>
        <div class="summary-card balance-card">
            <div class="icon">
                <svg width="22" height="22" fill="none" stroke="#3b82f6" stroke-width="2" viewBox="0 0 24 24">
                    <rect x="2" y="7" width="20" height="14" rx="2"/>
                    <path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/>
                </svg>
            </div>
            <div class="label">Net Balance</div>
            <div class="amount" id="netBalance">$0.00</div>
            <div class="sub">Available</div>
        </div>
    </div>

    <div class="content-grid">
        <div class="panel">
            <div class="panel-header">
                <h2>Transactions</h2>
                <div class="filter-tabs">
                    <button class="filter-tab active" onclick="filterTx('all',this)">All</button>
                    <button class="filter-tab" onclick="filterTx('income',this)">Income</button>
                    <button class="filter-tab" onclick="filterTx('expense',this)">Expense</button>
                </div>
            </div>
            <div class="tx-list" id="txList">
                <div class="empty-state"><div class="empty-icon">💸</div><div>Loading…</div></div>
            </div>
        </div>
        <div class="panel">
            <div class="panel-header"><h2>By Category</h2></div>
            <div class="cat-list" id="catList">
                <div class="empty-state" style="padding:40px 0">
                    <div class="empty-icon">📊</div><div>No data yet</div>
                </div>
            </div>
        </div>
    </div>
</main>

<!-- MODAL -->
<div class="modal-overlay" id="modalOverlay" onclick="closeModalOutside(event)">
    <div class="modal">
        <h2 id="modalTitle">Add Transaction</h2>
        <input type="hidden" id="editId">
        <div class="modal-field">
            <label>Type</label>
            <div class="type-toggle">
                <button class="type-btn active-income" id="btnIncome"  onclick="setType('income')">+ Income</button>
                <button class="type-btn"               id="btnExpense" onclick="setType('expense')">- Expense</button>
            </div>
        </div>
        <div class="modal-field">
            <label>Description</label>
            <input type="text" id="txDesc" placeholder="e.g. Grocery shopping">
        </div>
        <div class="modal-field">
            <label>Amount ($)</label>
            <input type="number" id="txAmount" placeholder="0.00" min="0" step="0.01">
        </div>
        <div class="modal-field">
            <label>Category</label>
            <select id="txCategory">
                <option value="Food">🍔 Food &amp; Dining</option>
                <option value="Transport">🚗 Transport</option>
                <option value="Shopping">🛍️ Shopping</option>
                <option value="Bills">💡 Bills &amp; Utilities</option>
                <option value="Health">❤️ Health</option>
                <option value="Entertainment">🎬 Entertainment</option>
                <option value="Education">📚 Education</option>
                <option value="Salary">💼 Salary</option>
                <option value="Investment">📈 Investment</option>
                <option value="Other">📦 Other</option>
            </select>
        </div>
        <div class="modal-field">
            <label>Date</label>
            <input type="date" id="txDate">
        </div>
        <div class="modal-actions">
            <button class="btn-cancel" onclick="closeModal()">Cancel</button>
            <button class="btn-save"   onclick="saveTransaction()">Save</button>
        </div>
    </div>
</div>

<script>
    var API = '<%= request.getContextPath() %>/api/expenses';

    var CAT_EMOJI = {};
    CAT_EMOJI['Food']          = '\uD83C\uDF54';
    CAT_EMOJI['Transport']     = '\uD83D\uDE97';
    CAT_EMOJI['Shopping']      = '\uD83D\uDECD\uFE0F';
    CAT_EMOJI['Bills']         = '\uD83D\uDCA1';
    CAT_EMOJI['Health']        = '\u2764\uFE0F';
    CAT_EMOJI['Entertainment'] = '\uD83C\uDFAC';
    CAT_EMOJI['Education']     = '\uD83D\uDCDA';
    CAT_EMOJI['Salary']        = '\uD83D\uDCBC';
    CAT_EMOJI['Investment']    = '\uD83D\uDCC8';
    CAT_EMOJI['Other']         = '\uD83D\uDCE6';

    var CAT_COLOR = {};
    CAT_COLOR['Food']          = '#f59e0b';
    CAT_COLOR['Transport']     = '#3b82f6';
    CAT_COLOR['Shopping']      = '#a855f7';
    CAT_COLOR['Bills']         = '#ef4444';
    CAT_COLOR['Health']        = '#ec4899';
    CAT_COLOR['Entertainment'] = '#06b6d4';
    CAT_COLOR['Education']     = '#8b5cf6';
    CAT_COLOR['Salary']        = '#22c55e';
    CAT_COLOR['Investment']    = '#10b981';
    CAT_COLOR['Other']         = '#64748b';

    function getCatEmoji(cat) { return CAT_EMOJI[cat] || CAT_EMOJI['Other']; }
    function getCatColor(cat) { return CAT_COLOR[cat] || CAT_COLOR['Other']; }

    var transactions  = [];
    var currentType   = 'income';
    var currentFilter = 'all';

    document.addEventListener('DOMContentLoaded', function() {
        var now = new Date();
        document.getElementById('currentDate').textContent =
            now.toLocaleDateString('en-US', {weekday:'long', year:'numeric', month:'long', day:'numeric'});
        document.getElementById('txDate').valueAsDate = now;
        loadTransactions();
    });

    function loadTransactions() {
        document.getElementById('loaderOverlay').classList.add('hidden');

        fetch(API)
            .then(function(res) {
                if (!res.ok) { throw new Error('Status ' + res.status); }
                return res.json();
            })
            .then(function(data) {
                transactions = Array.isArray(data) ? data : [];
                render();
            })
            .catch(function(err) {
                console.error('Load error:', err);
                transactions = [];
                render();
                showToast('Could not load transactions: ' + err.message, 'error');
            });
    }

    function render() {
        updateSummary();
        renderTransactions();
        renderCategories();
    }

    function updateSummary() {
        var income = 0, expenses = 0;
        for (var i = 0; i < transactions.length; i++) {
            if (transactions[i].type === 'income')  income   += transactions[i].amount;
            if (transactions[i].type === 'expense') expenses += transactions[i].amount;
        }
        var balance = income - expenses;
        document.getElementById('totalIncome').textContent   = fmt(income);
        document.getElementById('totalExpenses').textContent = fmt(expenses);
        var balEl = document.getElementById('netBalance');
        balEl.style.color = balance >= 0 ? 'var(--green)' : 'var(--red)';
        balEl.textContent = (balance < 0 ? '-' : '') + fmt(Math.abs(balance));
    }

    function renderTransactions() {
        var list = document.getElementById('txList');
        var filtered = [];
        for (var i = 0; i < transactions.length; i++) {
            if (currentFilter === 'all' || transactions[i].type === currentFilter) {
                filtered.push(transactions[i]);
            }
        }

        if (filtered.length === 0) {
            var label = currentFilter === 'all' ? '' : currentFilter + ' ';
            list.innerHTML =
                '<div class="empty-state">' +
                '<div class="empty-icon">\uD83D\uDCB8</div>' +
                '<div>No ' + label + 'transactions yet. Add one to get started!</div>' +
                '</div>';
            return;
        }

        var html = '';
        for (var j = 0; j < filtered.length; j++) {
            var t     = filtered[j];
            var emoji = getCatEmoji(t.category);
            var color = getCatColor(t.category);
            var sign  = t.type === 'income' ? '+' : '-';
            var cls   = t.type === 'income' ? 'income' : 'expense';
            html +=
                '<div class="tx-item fade-in">' +
                '<div class="tx-icon" style="background:' + color + '22">' + emoji + '</div>' +
                '<div class="tx-info">' +
                '<div class="tx-name">' + esc(t.description) + '</div>' +
                '<div class="tx-date">' + esc(t.category) + ' &middot; ' + fmtDate(t.date) + '</div>' +
                '</div>' +
                '<div class="tx-amount ' + cls + '">' + sign + fmt(t.amount) + '</div>' +
                '<div class="tx-actions">' +
                '<button class="tx-btn edit" onclick="openModal(' + t.id + ')" title="Edit">' +
                '<svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">' +
                '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>' +
                '<path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>' +
                '</svg></button>' +
                '<button class="tx-btn del" onclick="deleteTx(' + t.id + ')" title="Delete">' +
                '<svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">' +
                '<polyline points="3 6 5 6 21 6"/>' +
                '<path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>' +
                '<path d="M10 11v6"/><path d="M14 11v6"/>' +
                '</svg></button>' +
                '</div></div>';
        }
        list.innerHTML = html;
    }

    function renderCategories() {
        var catList = document.getElementById('catList');
        var totals  = {};
        var hasData = false;
        for (var i = 0; i < transactions.length; i++) {
            if (transactions[i].type === 'expense') {
                var c = transactions[i].category;
                totals[c] = (totals[c] || 0) + transactions[i].amount;
                hasData = true;
            }
        }
        if (!hasData) {
            catList.innerHTML =
                '<div class="empty-state" style="padding:40px 0">' +
                '<div class="empty-icon">\uD83D\uDCCA</div><div>No data yet</div></div>';
            return;
        }
        var max    = 0;
        var sorted = [];
        for (var cat in totals) {
            if (totals[cat] > max) max = totals[cat];
            sorted.push([cat, totals[cat]]);
        }
        sorted.sort(function(a, b) { return b[1] - a[1]; });

        var html = '';
        for (var k = 0; k < sorted.length; k++) {
            var name  = sorted[k][0];
            var amt   = sorted[k][1];
            var emoji = getCatEmoji(name);
            var color = getCatColor(name);
            var pct   = max > 0 ? (amt / max) * 100 : 0;
            html +=
                '<div class="cat-item">' +
                '<div class="cat-dot" style="background:' + color + '"></div>' +
                '<div class="cat-name">' + emoji + ' ' + esc(name) + '</div>' +
                '<div class="cat-bar-wrap"><div class="cat-bar" style="width:' + pct + '%;background:' + color + '"></div></div>' +
                '<div class="cat-amount">' + fmt(amt) + '</div>' +
                '</div>';
        }
        catList.innerHTML = html;
    }

    function openModal(id) {
        var editTx = null;
        if (id) {
            for (var i = 0; i < transactions.length; i++) {
                if (transactions[i].id === id) { editTx = transactions[i]; break; }
            }
        }
        document.getElementById('modalTitle').textContent = editTx ? 'Edit Transaction' : 'Add Transaction';
        document.getElementById('editId').value = editTx ? editTx.id : '';

        if (editTx) {
            setType(editTx.type);
            document.getElementById('txDesc').value     = editTx.description;
            document.getElementById('txAmount').value   = editTx.amount;
            document.getElementById('txCategory').value = editTx.category;
            document.getElementById('txDate').value     = editTx.date;
        } else {
            setType('income');
            document.getElementById('txDesc').value     = '';
            document.getElementById('txAmount').value   = '';
            document.getElementById('txDate').valueAsDate = new Date();
        }
        document.getElementById('modalOverlay').classList.add('open');
        setTimeout(function() { document.getElementById('txDesc').focus(); }, 100);
    }

    function closeModal() {
        document.getElementById('modalOverlay').classList.remove('open');
    }
    function closeModalOutside(e) {
        if (e.target === document.getElementById('modalOverlay')) closeModal();
    }
    function setType(type) {
        currentType = type;
        document.getElementById('btnIncome').className  = 'type-btn' + (type === 'income'  ? ' active-income'  : '');
        document.getElementById('btnExpense').className = 'type-btn' + (type === 'expense' ? ' active-expense' : '');
    }

    function saveTransaction() {
        var desc   = document.getElementById('txDesc').value.trim();
        var amount = parseFloat(document.getElementById('txAmount').value);
        var cat    = document.getElementById('txCategory').value;
        var date   = document.getElementById('txDate').value;
        var editId = document.getElementById('editId').value;

        if (!desc)               { showToast('Please enter a description.', 'error'); return; }
        if (!amount || amount <= 0) { showToast('Please enter a valid amount.', 'error'); return; }
        if (!date)               { showToast('Please select a date.', 'error'); return; }

        var body = new URLSearchParams();
        body.append('description', desc);
        body.append('amount', amount);
        body.append('category', cat);
        body.append('type', currentType);
        body.append('date', date);

        var url    = editId ? API + '/' + editId : API;
        var method = editId ? 'PUT' : 'POST';

        fetch(url, {method: method, body: body})
            .then(function(res) { return res.text(); })
            .then(function(text) {
                if (text.trim() === 'success') {
                    showToast(editId ? 'Transaction updated!' : 'Transaction added!', 'success');
                    closeModal();
                    loadTransactions();
                } else {
                    showToast('Error: ' + text, 'error');
                }
            })
            .catch(function() { showToast('Network error.', 'error'); });
    }

    function deleteTx(id) {
        if (!confirm('Delete this transaction?')) return;
        fetch(API + '/' + id, {method: 'DELETE'})
            .then(function(res) { return res.text(); })
            .then(function(text) {
                if (text.trim() === 'success') {
                    showToast('Transaction deleted.', 'error');
                    loadTransactions();
                }
            })
            .catch(function() { showToast('Network error.', 'error'); });
    }

    function filterTx(type, btn) {
        currentFilter = type;
        var tabs = document.querySelectorAll('.filter-tab');
        for (var i = 0; i < tabs.length; i++) tabs[i].classList.remove('active');
        btn.classList.add('active');
        renderTransactions();
    }

    function fmt(n)     { return '$' + n.toFixed(2); }
    function fmtDate(d) {
        if (!d) return '';
        var dt = new Date(d + 'T00:00:00');
        return dt.toLocaleDateString('en-US', {month:'short', day:'numeric', year:'numeric'});
    }
    function esc(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
    function showToast(msg, type) {
        var t = document.getElementById('toast');
        document.getElementById('toastMsg').textContent = msg;
        t.className = 'toast ' + type + ' show';
        clearTimeout(t._timer);
        t._timer = setTimeout(function() { t.classList.remove('show'); }, 3000);
    }
    document.addEventListener('keydown', function(e) { if (e.key === 'Escape') closeModal(); });
</script>
</body>
</html>

