let activeTab = "active-predictions";
let isAdminUser = false;
let activePredictionsData = {};
let historyPredictionsData = [];
let selectedOptions = {}; // Tracks selected option index per prediction ID (1-indexed)

// Default Configuration values loaded dynamically from client config
let Config = {
    MinBet: 10,
    MaxBet: 10000000,
    Currency: 'cash'
};

// Fetch data callback helper
function sendNUICallback(name, data = {}) {
    fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).catch(err => console.log('Callback error:', err));
}

// Show Toast Message
function showToast(message, type = 'info') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    
    let iconClass = 'fa-circle-info';
    if (type === 'success') iconClass = 'fa-circle-check';
    if (type === 'error') iconClass = 'fa-circle-exclamation';
    
    toast.innerHTML = `
        <i class="fa-solid ${iconClass}"></i>
        <span>${message}</span>
    `;
    
    container.appendChild(toast);
    
    // Auto remove toast
    setTimeout(() => {
        toast.style.animation = 'fadeIn 0.25s ease reverse';
        setTimeout(() => {
            toast.remove();
        }, 240);
    }, 4000);
}

// Close NUI wrapper
function closeUI() {
    document.getElementById('prediction-app').style.display = 'none';
    sendNUICallback('closeUI');
}

// Escape key to close UI
window.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') {
        closeUI();
    }
});

document.getElementById('close-btn').addEventListener('click', closeUI);

// Navigation Switcher
const navButtons = document.querySelectorAll('.nav-btn');
navButtons.forEach(btn => {
    btn.addEventListener('click', () => {
        const targetTab = btn.getAttribute('data-tab');
        
        // Remove active state
        navButtons.forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
        
        // Add active state
        btn.classList.add('active');
        document.getElementById(targetTab).classList.add('active');
        activeTab = targetTab;
    });
});

// Admin Option Creation dynamic elements
const optionsContainer = document.getElementById('options-inputs-container');
const addOptionBtn = document.getElementById('add-option-field-btn');

function updateOptionRemovers() {
    const rows = optionsContainer.querySelectorAll('.option-input-row');
    const removeButtons = optionsContainer.querySelectorAll('.remove-option-btn');
    
    removeButtons.forEach(btn => {
        btn.disabled = rows.length <= 2;
    });
}

addOptionBtn.addEventListener('click', () => {
    const rows = optionsContainer.querySelectorAll('.option-input-row');
    if (rows.length >= 10) {
        showToast("Maximum 10 options allowed", "error");
        return;
    }
    
    const newIndex = rows.length + 1;
    const newRow = document.createElement('div');
    newRow.className = 'option-input-row';
    newRow.innerHTML = `
        <div class="option-number">${newIndex}</div>
        <input type="text" class="option-input" placeholder="Option ${newIndex}" required autocomplete="off">
        <button type="button" class="remove-option-btn"><i class="fa-solid fa-trash-can"></i></button>
    `;
    
    // Add remove functionality
    newRow.querySelector('.remove-option-btn').addEventListener('click', () => {
        newRow.remove();
        updateOptionRemovers();
        // Re-index placeholders and numbers
        const remainingRows = optionsContainer.querySelectorAll('.option-input-row');
        remainingRows.forEach((r, idx) => {
            const currentIdx = idx + 1;
            r.querySelector('.option-number').textContent = currentIdx;
            r.querySelector('input').placeholder = `Option ${currentIdx}`;
        });
    });
    
    optionsContainer.appendChild(newRow);
    updateOptionRemovers();
});

// Setup initially disabled standard remove buttons
updateOptionRemovers();

// Type Pill Selector logic
document.querySelectorAll('.type-pill-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.type-pill-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        document.getElementById('pred-type').value = btn.getAttribute('data-type');
    });
});

// Create Prediction Form Submission
document.getElementById('create-prediction-form').addEventListener('submit', (e) => {
    e.preventDefault();
    
    const question = document.getElementById('pred-question').value.trim();
    const type = document.getElementById('pred-type').value;
    const showStats = document.getElementById('pred-show-stats').checked;
    const hideUntilEnded = document.getElementById('pred-hide-until-ended').checked;
    
    const optionInputs = optionsContainer.querySelectorAll('.option-input');
    const options = [];
    optionInputs.forEach(input => {
        const val = input.value.trim();
        if (val) options.push(val);
    });
    
    if (options.length < 2) {
        showToast("Minimum 2 options required", "error");
        return;
    }

    sendNUICallback('createPrediction', {
        question: question,
        type: type,
        options: options,
        showStats: showStats,
        hideUntilEnded: hideUntilEnded
    });

    // Reset Form
    document.getElementById('pred-question').value = '';
    optionsContainer.innerHTML = `
        <div class="option-input-row">
            <div class="option-number">1</div>
            <input type="text" class="option-input" placeholder="Option 1" required autocomplete="off">
            <button type="button" class="remove-option-btn" disabled><i class="fa-solid fa-trash-can"></i></button>
        </div>
        <div class="option-input-row">
            <div class="option-number">2</div>
            <input type="text" class="option-input" placeholder="Option 2" required autocomplete="off">
            <button type="button" class="remove-option-btn" disabled><i class="fa-solid fa-trash-can"></i></button>
        </div>
    `;
    updateOptionRemovers();
    
    // Reset Privacy Checkboxes
    document.getElementById('pred-show-stats').checked = true;
    document.getElementById('pred-hide-until-ended').checked = false;
    
    // Reset Type Pill Selector to default
    document.querySelector('.type-pill-btn[data-type="prediction"]').click();
});

// Listen to Client Messages
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === "openUI") {
        document.getElementById('prediction-app').style.display = 'flex';
        isAdminUser = data.isAdmin;
        
        // Dynamic config loading from client
        if (data.config) {
            Config.MinBet = parseInt(data.config.minBet) || 10;
            Config.MaxBet = parseInt(data.config.maxBet) || 10000000;
            Config.Currency = data.config.currency || 'cash';
            
            const currencyEl = document.getElementById('config-currency');
            if (currencyEl) {
                currencyEl.textContent = Config.Currency.charAt(0).toUpperCase() + Config.Currency.slice(1);
            }
        }
        
        // Hide/Show Admin controls in Sidebar
        const adminBtn = document.querySelector('.admin-only');
        if (isAdminUser) {
            adminBtn.style.display = 'flex';
        } else {
            adminBtn.style.display = 'none';
            // Fallback if client somehow was in admin panel tab
            if (activeTab === "admin-panel") {
                document.querySelector('.nav-btn[data-tab="active-predictions"]').click();
            }
        }
    }
    
    if (data.action === "syncData") {
        activePredictionsData = data.active || {};
        historyPredictionsData = data.history || [];
        
        renderActivePredictions();
        renderHistoryPredictions();
        
        if (isAdminUser) {
            renderAdminActivePredictions();
        }
        
        // Update navigation badge counts
        const activeCount = Object.keys(activePredictionsData).length;
        document.getElementById('active-badge').textContent = activeCount;
    }
    
    if (data.action === "notify") {
        showToast(data.message, data.type);
    }
});

// Render Voter Active Predictions
function renderActivePredictions() {
    const listContainer = document.getElementById('active-predictions-list');
    listContainer.innerHTML = '';
    
    const activeKeys = Object.keys(activePredictionsData);
    
    if (activeKeys.length === 0) {
        listContainer.innerHTML = `
            <div class="empty-state">
                <i class="fa-solid fa-circle-question"></i>
                <h3>No Active Predictions</h3>
                <p>There are no active prediction events or polls right now. Check back later!</p>
            </div>
        `;
        return;
    }
    
    // Sort active predictions by timestamp (newest first)
    const sortedPredictions = Object.values(activePredictionsData).sort((a, b) => b.createdAt - a.createdAt);
    
    sortedPredictions.forEach(pred => {
        const card = document.createElement('div');
        card.className = 'prediction-card';
        card.id = `card-${pred.id}`;
        
        const isMoneyBased = pred.type === 'prediction';
        const typeBadge = isMoneyBased 
            ? `<span class="badge-tag money-tag"><i class="fa-solid fa-dollar-sign"></i> Prediction</span>`
            : `<span class="badge-tag poll-tag"><i class="fa-solid fa-square-poll-vertical"></i> Poll</span>`;
            
        const isClosed = pred.status === 'closed';
        const statusText = isClosed ? 'Voting Closed' : 'Voting Open';
        const statusClass = isClosed ? 'closed' : 'open';
        
        // Total Pool Size Header
        let poolHeaderHtml = '';
        const statsMasked = (pred.hideUntilEnded) || (pred.showStats === false && !pred.myVote);
        if (isMoneyBased) {
            const displayPool = statsMasked ? "Hidden" : `$${pred.totalPool.toLocaleString()}`;
            poolHeaderHtml = `
                <div class="pool-info">
                    <span>Total Pool: <strong>${displayPool}</strong></span>
                </div>
            `;
        } else {
            const displayVotes = statsMasked ? "Hidden" : pred.totalPool;
            poolHeaderHtml = `
                <div class="pool-info">
                    <span>Total Votes: <strong>${displayVotes}</strong></span>
                </div>
            `;
        }

        // Render Options Listing
        let optionsHtml = '<div class="options-container">';
        pred.options.forEach((opt, idx) => {
            const optIndex = idx + 1;
            const totalOptVal = (Array.isArray(pred.totals) ? pred.totals[idx] : pred.totals[optIndex]) || 0;
            const percentage = pred.totalPool > 0 ? Math.round((totalOptVal / pred.totalPool) * 100) : 0;
            
            // Check if player has voted for this option
            let isVoted = false;
            let isSelected = false;
            
            if (pred.myVote && pred.myVote.option === optIndex) {
                isVoted = true;
            }
            
            if (selectedOptions[pred.id] === optIndex) {
                isSelected = true;
            }
            
            const rowClass = `${isVoted ? 'voted-highlight' : ''} ${isSelected ? 'selected' : ''} ${isClosed || pred.myVote ? 'disabled' : ''}`;
            const clickHandler = isClosed || pred.myVote ? '' : `onclick="selectOption('${pred.id}', ${optIndex})"`;
            
            const progressWidth = statsMasked ? 0 : percentage;
            const percentageText = statsMasked ? "—" : `${percentage}%`;
            const displayVal = statsMasked ? "Hidden" : (isMoneyBased ? `$${totalOptVal.toLocaleString()}` : `${totalOptVal} votes`);

            optionsHtml += `
                <div class="option-row ${rowClass}" ${clickHandler}>
                    <div class="progress-fill" style="width: ${progressWidth}%"></div>
                    <div class="option-content">
                        <div class="option-text-group">
                            <div class="option-checkbox">
                                <i class="fa-solid fa-check"></i>
                            </div>
                            <span class="option-name">${opt}</span>
                        </div>
                        <div class="option-stats">
                            <span class="option-percentage">${percentageText}</span>
                            <span class="option-amount">${displayVal}</span>
                        </div>
                    </div>
                </div>
            `;
        });
        optionsHtml += '</div>';

        // Render Vote Input Module (only if player has NOT voted yet)
        let voteModuleHtml = '';
        if (!pred.myVote && !isClosed) {
            const hasSelected = selectedOptions[pred.id] !== undefined;
            const submitBtnDisabled = !hasSelected ? 'disabled' : '';
            
            if (isMoneyBased) {
                voteModuleHtml = `
                    <div class="bet-submission-panel" id="submission-${pred.id}">
                        <label>Betting Capital</label>
                        <div class="bet-input-wrapper">
                            <div class="bet-input-field">
                                <span>$</span>
                                <input type="number" min="${Config.MinBet}" max="${Config.MaxBet}" id="bet-val-${pred.id}" placeholder="Enter amount..." autocomplete="off">
                            </div>
                            <button class="primary-btn" ${submitBtnDisabled} id="submit-btn-${pred.id}" onclick="submitVote('${pred.id}')">
                                <i class="fa-solid fa-hand-holding-dollar"></i> Place Bet
                            </button>
                        </div>
                        <div class="bet-presets">
                            <button class="preset-btn" onclick="applyPreset('${pred.id}', 100)">+$100</button>
                            <button class="preset-btn" onclick="applyPreset('${pred.id}', 1000)">+$1,000</button>
                            <button class="preset-btn" onclick="applyPreset('${pred.id}', 10000)">+$10,000</button>
                            <button class="preset-btn" onclick="applyPreset('${pred.id}', 100000)">+$100,000</button>
                        </div>
                    </div>
                `;
            } else {
                voteModuleHtml = `
                    <div class="bet-submission-panel" id="submission-${pred.id}">
                        <button class="primary-btn submit-btn" ${submitBtnDisabled} id="submit-btn-${pred.id}" onclick="submitVote('${pred.id}')">
                            <i class="fa-solid fa-vote-yea"></i> Cast Vote
                        </button>
                    </div>
                `;
            }
        } else if (pred.myVote) {
            // Player already voted badge
            const votedOptName = pred.options[pred.myVote.option - 1];
            if (isMoneyBased) {
                voteModuleHtml = `
                    <div class="vote-confirmation-badge">
                        <span>You placed a bet on <strong>${votedOptName}</strong></span>
                        <span>Investment: <strong>$${pred.myVote.amount.toLocaleString()}</strong></span>
                    </div>
                `;
            } else {
                voteModuleHtml = `
                    <div class="vote-confirmation-badge">
                        <span>You voted for option: <strong>${votedOptName}</strong></span>
                        <span><i class="fa-solid fa-circle-check"></i> Recorded</span>
                    </div>
                `;
            }
        } else if (isClosed && !pred.myVote) {
            voteModuleHtml = `
                <div class="vote-confirmation-badge" style="background: rgba(245, 158, 11, 0.04); border-color: rgba(245, 158, 11, 0.2); color: var(--warning);">
                    <span>Voting closed before you could cast a vote.</span>
                </div>
            `;
        }

        card.innerHTML = `
            <div class="card-meta">
                ${typeBadge}
                <div class="status-indicator ${statusClass}">
                    <span class="status-dot"></span>
                    <span>${statusText}</span>
                </div>
            </div>
            <h2 class="card-question">${pred.question}</h2>
            ${poolHeaderHtml}
            ${optionsHtml}
            ${voteModuleHtml}
        `;
        
        listContainer.appendChild(card);
    });
}

// Option selector inside voter panel
window.selectOption = function(predId, optionIndex) {
    selectedOptions[predId] = optionIndex;
    
    // Redraw this active prediction card immediately
    renderActivePredictions();
};

window.applyPreset = function(predId, amount) {
    const input = document.getElementById(`bet-val-${predId}`);
    if (input) {
        let val = parseInt(input.value) || 0;
        input.value = val + amount;
    }
};

window.submitVote = function(predId) {
    const selectedOpt = selectedOptions[predId];
    if (!selectedOpt) return;
    
    const pred = activePredictionsData[predId];
    let amount = 0;
    
    if (pred && pred.type === 'prediction') {
        const input = document.getElementById(`bet-val-${predId}`);
        amount = parseInt(input?.value) || 0;
        
        if (amount < Config.MinBet) {
            showToast(`Minimum bet is $${Config.MinBet}`, "error");
            return;
        }
    }
    
    sendNUICallback('castVote', {
        predictionId: predId,
        optionIndex: selectedOpt,
        betAmount: amount
    });
    
    // Clear selection
    delete selectedOptions[predId];
};

// Render Prediction History Tab
function renderHistoryPredictions() {
    const listContainer = document.getElementById('history-predictions-list');
    listContainer.innerHTML = '';
    
    if (historyPredictionsData.length === 0) {
        listContainer.innerHTML = `
            <div class="empty-state">
                <i class="fa-solid fa-box-open"></i>
                <h3>History is Empty</h3>
                <p>No predictions have been archived yet.</p>
            </div>
        `;
        return;
    }
    
    // Sort history by resolved date (newest first)
    const sortedHistory = [...historyPredictionsData].sort((a, b) => b.endedAt - a.endedAt);
    
    sortedHistory.forEach(pred => {
        const card = document.createElement('div');
        card.className = 'prediction-card';
        
        const isMoneyBased = pred.type === 'prediction';
        const typeBadge = isMoneyBased 
            ? `<span class="badge-tag money-tag"><i class="fa-solid fa-dollar-sign"></i> Prediction</span>`
            : `<span class="badge-tag poll-tag"><i class="fa-solid fa-square-poll-vertical"></i> Poll</span>`;
            
        const winnerName = pred.options[pred.winner - 1];
        
        let poolInfoHtml = '';
        if (isMoneyBased) {
            poolInfoHtml = `
                <div class="pool-info">
                    <span>Total Pool: <strong>$${pred.totalPool.toLocaleString()}</strong></span>
                </div>
            `;
        } else {
            poolInfoHtml = `
                <div class="pool-info">
                    <span>Total Votes: <strong>${pred.totalPool}</strong></span>
                </div>
            `;
        }

        let optionsHtml = '<div class="options-container">';
        pred.options.forEach((opt, idx) => {
            const optIndex = idx + 1;
            const totalOptVal = (Array.isArray(pred.totals) ? pred.totals[idx] : pred.totals[optIndex]) || 0;
            const percentage = pred.totalPool > 0 ? Math.round((totalOptVal / pred.totalPool) * 100) : 0;
            
            const isWinner = pred.winner === optIndex;
            const rowClass = isWinner ? 'winner-highlight' : 'disabled';
            const displayVal = isMoneyBased ? `$${totalOptVal.toLocaleString()}` : `${totalOptVal} votes`;

            optionsHtml += `
                <div class="option-row ${rowClass}">
                    <div class="progress-fill" style="width: ${percentage}%"></div>
                    <div class="option-content">
                        <div class="option-text-group">
                            <div class="option-checkbox">
                                <i class="fa-solid fa-crown"></i>
                            </div>
                            <span class="option-name">${opt}</span>
                        </div>
                        <div class="option-stats">
                            <span class="option-percentage">${percentage}%</span>
                            <span class="option-amount">${displayVal}</span>
                        </div>
                    </div>
                </div>
            `;
        });
        optionsHtml += '</div>';

        // Display how much money a user got back / lost
        let myVoteHtml = '';
        if (pred.myVote) {
            const votedOptName = pred.options[pred.myVote.option - 1];
            if (isMoneyBased) {
                const isWinner = pred.myVote.option === pred.winner;
                if (isWinner) {
                    myVoteHtml = `
                        <div class="vote-confirmation-badge" style="background: rgba(34, 197, 94, 0.08); border-color: rgba(34, 197, 94, 0.3); color: var(--success); margin-top: 15px;">
                            <span>You backed the winner <strong>${votedOptName}</strong>!</span>
                            <span>Payout: <strong>+$${pred.myVote.payout.toLocaleString()}</strong> (Profit: +$${(pred.myVote.payout - pred.myVote.amount).toLocaleString()})</span>
                        </div>
                    `;
                } else {
                    myVoteHtml = `
                        <div class="vote-confirmation-badge" style="background: rgba(239, 68, 68, 0.08); border-color: rgba(239, 68, 68, 0.3); color: var(--error); margin-top: 15px;">
                            <span>You backed <strong>${votedOptName}</strong></span>
                            <span>Loss: <strong>-$${pred.myVote.amount.toLocaleString()}</strong></span>
                        </div>
                    `;
                }
            } else {
                myVoteHtml = `
                    <div class="vote-confirmation-badge" style="margin-top: 15px;">
                        <span>You voted for option: <strong>${votedOptName}</strong></span>
                        <span><i class="fa-solid fa-check-double"></i> Recorded</span>
                    </div>
                `;
            }
        }

        card.innerHTML = `
            <div class="card-meta">
                ${typeBadge}
                <div class="status-indicator ended">
                    <span class="status-dot"></span>
                    <span>Resolved</span>
                </div>
            </div>
            <h2 class="card-question">${pred.question}</h2>
            <div class="winner-badge"><i class="fa-solid fa-trophy"></i> Winner: <strong>${winnerName}</strong></div>
            ${poolInfoHtml}
            ${optionsHtml}
            ${myVoteHtml}
        `;
        
        listContainer.appendChild(card);
    });
}

// Render Admin Active list management (Tab 3 column 2)
function renderAdminActivePredictions() {
    const listContainer = document.getElementById('admin-active-list');
    listContainer.innerHTML = '';
    
    const activeList = Object.values(activePredictionsData).sort((a, b) => b.createdAt - a.createdAt);
    
    if (activeList.length === 0) {
        listContainer.innerHTML = `
            <div class="empty-state">
                <i class="fa-solid fa-face-smile"></i>
                <h3>No events to manage</h3>
                <p>Launch an event to start controlling it here.</p>
            </div>
        `;
        return;
    }
    
    activeList.forEach(pred => {
        const item = document.createElement('div');
        item.className = 'manage-item';
        
        const isMoney = pred.type === 'prediction';
        const typeLabel = isMoney ? 'Prediction' : 'Poll';
        const displayTotal = isMoney ? `$${pred.totalPool.toLocaleString()}` : `${pred.totalPool} votes`;
        
        let actionsHtml = '';
        
        // Render actions based on status
        if (pred.status === 'open') {
            actionsHtml = `
                <div class="manage-actions">
                    <button class="btn-close" onclick="adminCloseVoting('${pred.id}')"><i class="fa-solid fa-lock"></i> Close Voting</button>
                    <button class="btn-cancel" onclick="adminCancelPrediction('${pred.id}')"><i class="fa-solid fa-ban"></i> Refund/Cancel</button>
                </div>
            `;
        } else if (pred.status === 'closed') {
            // Dropdown options selector to resolve and payout
            let resolveOptions = '';
            pred.options.forEach((opt, idx) => {
                resolveOptions += `<option value="${idx + 1}">${opt}</option>`;
            });
            
            actionsHtml = `
                <div class="end-selection-wrapper">
                    <label>Select Winning Option</label>
                    <select id="winner-select-${pred.id}">
                        ${resolveOptions}
                    </select>
                    <div class="end-confirm-actions">
                        <button class="btn-end" onclick="adminConfirmEndPrediction('${pred.id}')"><i class="fa-solid fa-circle-check"></i> Payout Winner</button>
                        <button class="btn-cancel" style="flex: 0.5" onclick="adminCancelPrediction('${pred.id}')">Cancel</button>
                    </div>
                </div>
            `;
        }

        item.innerHTML = `
            <div class="manage-item-header">
                <span class="manage-item-title">${pred.question}</span>
                <span class="manage-item-type">${typeLabel}</span>
            </div>
            <div class="manage-item-stats">
                <span>Status: <strong style="color: ${pred.status === 'open' ? 'var(--success)' : 'var(--warning)'}">${pred.status.toUpperCase()}</strong></span> | 
                <span>Total Pool: <strong>${displayTotal}</strong></span>
            </div>
            ${actionsHtml}
        `;
        
        listContainer.appendChild(item);
    });
}

// Custom In-UI Confirmation Modal
let confirmCallback = null;

function showConfirm(message, callback) {
    const modal = document.getElementById('confirm-modal');
    const messageEl = document.getElementById('confirm-message');
    if (!modal || !messageEl) return;
    
    messageEl.textContent = message;
    confirmCallback = callback;
    modal.style.display = 'flex';
}

document.getElementById('confirm-cancel-btn').addEventListener('click', () => {
    document.getElementById('confirm-modal').style.display = 'none';
    confirmCallback = null;
});

document.getElementById('confirm-ok-btn').addEventListener('click', () => {
    document.getElementById('confirm-modal').style.display = 'none';
    if (confirmCallback) {
        confirmCallback();
        confirmCallback = null;
    }
});

// Admin Commands callbacks
window.adminCloseVoting = function(predId) {
    sendNUICallback('closeVoting', { predictionId: predId });
};

window.adminCancelPrediction = function(predId) {
    showConfirm("Are you absolutely sure you want to cancel this event and refund all bets?", () => {
        sendNUICallback('cancelPrediction', { predictionId: predId });
    });
};

window.adminConfirmEndPrediction = function(predId) {
    const select = document.getElementById(`winner-select-${predId}`);
    const winningIdx = parseInt(select?.value);
    if (!winningIdx) return;
    
    showConfirm("Resolve prediction and distribute money pool to selected winner? This action is irreversible.", () => {
        sendNUICallback('endPrediction', {
            predictionId: predId,
            winningOptionIndex: winningIdx
        });
    });
};
