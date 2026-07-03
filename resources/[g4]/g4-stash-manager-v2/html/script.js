// Global State
let dbData = { stashes: {}, shops: {} };
let currentType = 'stash'; // Create Point selection

// DOM elements
const appContainer = document.getElementById('app-container');
const tabButtons = document.querySelectorAll('.nav-btn');
const tabContents = document.querySelectorAll('.tab-content');

// Forms & Dynamic Rows
const createPointForm = document.getElementById('create-point-form');
const accessRowsContainer = document.getElementById('access-rows-container');
const editStashAccessRows = document.getElementById('edit-stash-access-rows');
const editShopAccessRows = document.getElementById('edit-shop-access-rows');
const shopItemsRowsContainer = document.getElementById('shop-items-rows-container');

// Search elements
const searchStashesInput = document.getElementById('search-stashes');
const searchShopsInput = document.getElementById('search-shops');

// Toast Notification helper
function showToast(message, type = 'success') {
    const toast = document.getElementById('toast');
    const icon = toast.querySelector('.toast-icon');
    const text = toast.querySelector('.toast-text');
    
    text.innerText = message;
    if (type === 'error') {
        toast.style.borderLeftColor = 'var(--danger)';
        icon.className = 'toast-icon fa-solid fa-circle-xmark';
        icon.style.color = 'var(--danger)';
    } else {
        toast.style.borderLeftColor = 'var(--success)';
        icon.className = 'toast-icon fa-solid fa-circle-check';
        icon.style.color = 'var(--success)';
    }
    
    toast.classList.remove('hidden');
    setTimeout(() => {
        toast.classList.add('hidden');
    }, 3000);
}

// Post helper
function sendNUIPost(endpoint, data = {}) {
    fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    }).catch(err => console.log('NUI Post Error:', err));
}

// Modal open/close
function openModal(id) {
    document.getElementById(id).classList.remove('hidden');
}

function closeModal(id) {
    document.getElementById(id).classList.add('hidden');
}

// Dynamic input row generators
function createAccessRow(container, group = '', grade = 0) {
    const div = document.createElement('div');
    div.className = 'access-row';
    div.innerHTML = `
        <input type="text" placeholder="e.g. police" class="access-group-name" value="${group}" required>
        <input type="number" placeholder="Min Grade (e.g. 0)" class="access-group-grade" value="${grade}" min="0" required>
        <button type="button" class="action-btn btn-delete remove-row-btn"><i class="fa-solid fa-trash"></i></button>
    `;
    div.querySelector('.remove-row-btn').addEventListener('click', () => div.remove());
    container.appendChild(div);
}

function addShopItemRow(name = '', price = 1) {
    const tr = document.createElement('tr');
    tr.innerHTML = `
        <td><input type="text" placeholder="e.g., water" class="item-name-input" value="${name}" required style="width: 100%; background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 6px; padding: 8px 12px; color: var(--text-white);"></td>
        <td><input type="number" placeholder="e.g., 5" class="item-price-input" value="${price}" min="0" required style="width: 100%; background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 6px; padding: 8px 12px; color: var(--text-white);"></td>
        <td>
            <button type="button" class="action-btn btn-delete remove-item-row-btn"><i class="fa-solid fa-trash"></i></button>
        </td>
    `;
    tr.querySelector('.remove-item-row-btn').addEventListener('click', () => tr.remove());
    shopItemsRowsContainer.appendChild(tr);
}

// Parse Access inputs to JSON object or null
function serializeAccess(container) {
    const rows = container.querySelectorAll('.access-row');
    if (rows.length === 0) return null;
    
    const access = {};
    rows.forEach(row => {
        const group = row.querySelector('.access-group-name').value.trim();
        const grade = parseInt(row.querySelector('.access-group-grade').value) || 0;
        if (group) {
            access[group] = grade;
        }
    });
    return Object.keys(access).length > 0 ? access : null;
}

// Tab switcher logic
tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
        tabButtons.forEach(b => b.classList.remove('active'));
        tabContents.forEach(c => c.classList.remove('active'));
        
        btn.classList.add('active');
        document.getElementById(`tab-${btn.dataset.tab}`).classList.add('active');
    });
});

// Create Point Form Type Selector logic
document.querySelectorAll('.selector-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.selector-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentType = btn.dataset.type;
        
        const stashElements = document.querySelectorAll('.stash-only');
        if (currentType === 'shop') {
            stashElements.forEach(el => el.classList.add('hidden'));
        } else {
            stashElements.forEach(el => el.classList.remove('hidden'));
        }
    });
});

// Teleport trigger
function handleTeleport(coords) {
    sendNUIPost('teleportTo', { coords });
    showToast("Teleported successfully!");
}

// Confirmation Modal helper
let confirmCallback = null;
function showConfirmModal(title, text, onConfirm) {
    document.getElementById('confirm-title').innerText = title;
    document.getElementById('confirm-text').innerText = text;
    confirmCallback = onConfirm;
    openModal('confirm-modal');
}

// Delete config trigger
function handleDelete(type, id) {
    showConfirmModal(
        `Delete ${type.toUpperCase()}`,
        `Are you sure you want to delete this ${type}? (ID: ${id}) This action is permanent and cannot be undone.`,
        () => {
            sendNUIPost('deleteConfig', { type, id });
            showToast("Point deleted successfully!");
        }
    );
}


// Render Listings
function renderStashes() {
    const listBody = document.getElementById('stashes-list-body');
    listBody.innerHTML = '';
    const query = searchStashesInput.value.toLowerCase().trim();
    
    let count = 0;
    let restricted = 0;
    
    Object.keys(dbData.stashes).forEach(key => {
        const stash = dbData.stashes[key];
        count++;
        
        const matchesSearch = stash.id.toLowerCase().includes(query) || stash.label.toLowerCase().includes(query);
        if (!matchesSearch) return;

        const isRestricted = stash.access && Object.keys(stash.access).length > 0;
        if (isRestricted) restricted++;
        
        const tr = document.createElement('tr');
        
        // Access Badging
        let accessBadge = '<span class="badge badge-public"><i class="fa-solid fa-lock-open"></i> Public</span>';
        if (isRestricted) {
            const list = Object.keys(stash.access).map(k => `${k}:${stash.access[k]}`).join(', ');
            accessBadge = `<span class="badge badge-restricted" title="${list}"><i class="fa-solid fa-lock"></i> Restricted</span>`;
        }

        tr.innerHTML = `
            <td><strong>${stash.id}</strong></td>
            <td>${stash.label}</td>
            <td>${stash.slots}</td>
            <td>${(stash.weight / 1000).toFixed(1)} kg</td>
            <td>${accessBadge}</td>
            <td>
                <div class="actions-cell">
                    <button class="action-btn btn-edit" title="Edit Properties" onclick="openEditStashModal('${stash.id}')"><i class="fa-solid fa-pen-to-square"></i></button>
                    <button class="action-btn btn-items" title="Configure Items" onclick="openStashItemsModal('${stash.id}')"><i class="fa-solid fa-boxes-stacked"></i></button>
                    <button class="action-btn btn-tp" title="Teleport to Stash" onclick='handleTeleport(${JSON.stringify(stash.coords)})'><i class="fa-solid fa-location-arrow"></i></button>
                    <button class="action-btn btn-delete" title="Delete Stash" onclick="handleDelete('stash', '${stash.id}')"><i class="fa-solid fa-trash"></i></button>
                </div>
            </td>
        `;
        listBody.appendChild(tr);
    });
    
    document.getElementById('stat-total-stashes').innerText = count;
}

function renderShops() {
    const listBody = document.getElementById('shops-list-body');
    listBody.innerHTML = '';
    const query = searchShopsInput.value.toLowerCase().trim();
    
    let count = 0;
    let restricted = 0;
    
    Object.keys(dbData.shops).forEach(key => {
        const shop = dbData.shops[key];
        count++;
        
        const matchesSearch = shop.id.toLowerCase().includes(query) || shop.label.toLowerCase().includes(query);
        if (!matchesSearch) return;

        const isRestricted = shop.access && Object.keys(shop.access).length > 0;
        if (isRestricted) restricted++;
        
        const tr = document.createElement('tr');
        
        // Access Badging
        let accessBadge = '<span class="badge badge-public"><i class="fa-solid fa-lock-open"></i> Public</span>';
        if (isRestricted) {
            const list = Object.keys(shop.access).map(k => `${k}:${shop.access[k]}`).join(', ');
            accessBadge = `<span class="badge badge-restricted" title="${list}"><i class="fa-solid fa-lock"></i> Restricted</span>`;
        }

        const itemsCount = shop.items ? shop.items.length : 0;

        tr.innerHTML = `
            <td><strong>${shop.id}</strong></td>
            <td>${shop.label}</td>
            <td><span class="badge badge-public"><i class="fa-solid fa-box"></i> ${itemsCount} items</span></td>
            <td>${accessBadge}</td>
            <td>
                <div class="actions-cell">
                    <button class="action-btn btn-edit" title="Edit Properties" onclick="openEditShopModal('${shop.id}')"><i class="fa-solid fa-pen-to-square"></i></button>
                    <button class="action-btn btn-items" title="Configure Inventory" onclick="openShopItemsModal('${shop.id}')"><i class="fa-solid fa-boxes-stacked"></i></button>
                    <button class="action-btn btn-tp" title="Teleport to Shop" onclick='handleTeleport(${JSON.stringify(shop.coords)})'><i class="fa-solid fa-location-arrow"></i></button>
                    <button class="action-btn btn-delete" title="Delete Shop" onclick="handleDelete('shop', '${shop.id}')"><i class="fa-solid fa-trash"></i></button>
                </div>
            </td>
        `;
        listBody.appendChild(tr);
    });
    
    document.getElementById('stat-total-shops').innerText = count;
    
    // Update global dashboard statistics
    const totalStashes = Object.keys(dbData.stashes).length;
    let totalRestricted = 0;
    
    Object.keys(dbData.stashes).forEach(k => {
        if (dbData.stashes[k].access && Object.keys(dbData.stashes[k].access).length > 0) totalRestricted++;
    });
    Object.keys(dbData.shops).forEach(k => {
        if (dbData.shops[k].access && Object.keys(dbData.shops[k].access).length > 0) totalRestricted++;
    });
    
    document.getElementById('stat-total-restricted').innerText = totalRestricted;
}

// Edit Modal Opening Logic
window.openEditStashModal = function(stashId) {
    const stash = dbData.stashes[stashId];
    if (!stash) return;
    
    document.getElementById('edit-stash-original-id').value = stash.id;
    document.getElementById('edit-stash-id').value = stash.id;
    document.getElementById('edit-stash-label').value = stash.label;
    document.getElementById('edit-stash-slots').value = stash.slots;
    document.getElementById('edit-stash-weight').value = stash.weight;
    
    document.getElementById('edit-stash-x').value = stash.coords.x;
    document.getElementById('edit-stash-y').value = stash.coords.y;
    document.getElementById('edit-stash-z').value = stash.coords.z;
    
    editStashAccessRows.innerHTML = '';
    if (stash.access) {
        Object.keys(stash.access).forEach(group => {
            createAccessRow(editStashAccessRows, group, stash.access[group]);
        });
    }
    
    openModal('edit-stash-modal');
};

window.openEditShopModal = function(shopId) {
    const shop = dbData.shops[shopId];
    if (!shop) return;
    
    document.getElementById('edit-shop-original-id').value = shop.id;
    document.getElementById('edit-shop-id').value = shop.id;
    document.getElementById('edit-shop-label').value = shop.label;
    
    document.getElementById('edit-shop-x').value = shop.coords.x;
    document.getElementById('edit-shop-y').value = shop.coords.y;
    document.getElementById('edit-shop-z').value = shop.coords.z;
    
    editShopAccessRows.innerHTML = '';
    if (shop.access) {
        Object.keys(shop.access).forEach(group => {
            createAccessRow(editShopAccessRows, group, shop.access[group]);
        });
    }
    
    openModal('edit-shop-modal');
};

window.openShopItemsModal = function(shopId) {
    const shop = dbData.shops[shopId];
    if (!shop) return;
    
    document.getElementById('shop-items-title').innerText = `Configure Shop Inventory`;
    document.getElementById('shop-items-subtitle').innerText = `Shop ID: ${shop.id}`;
    document.getElementById('btn-save-shop-items').dataset.shopId = shop.id;
    
    shopItemsRowsContainer.innerHTML = '';
    const items = shop.items || [];
    items.forEach(item => {
        addShopItemRow(item.name, item.price);
    });
    
    openModal('shop-items-modal');
};

// Stash Bulk Add/Remove Logic
let pendingStashRemovals = {};

function addStashBulkAddRow(name = '', count = 1) {
    const tbody = document.getElementById('stash-bulk-add-body');
    const tr = document.createElement('tr');
    tr.innerHTML = `
        <td><input type="text" placeholder="e.g. water" class="bulk-add-name" value="${name}" required style="width: 100%; background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 6px; padding: 8px 12px; color: var(--text-white);"></td>
        <td><input type="number" placeholder="Count" class="bulk-add-count" value="${count}" min="1" required style="width: 100%; background: var(--bg-input); border: 1px solid var(--border-color); border-radius: 6px; padding: 8px 12px; color: var(--text-white);"></td>
        <td>
            <button type="button" class="action-btn btn-delete remove-bulk-row-btn"><i class="fa-solid fa-trash"></i></button>
        </td>
    `;
    tr.querySelector('.remove-bulk-row-btn').addEventListener('click', () => tr.remove());
    tbody.appendChild(tr);
}

window.openStashItemsModal = function(stashId) {
    const stash = dbData.stashes[stashId];
    if (!stash) return;

    document.getElementById('stash-items-title').innerText = `Manage Stash Inventory`;
    document.getElementById('stash-items-subtitle').innerText = `Stash ID: ${stash.id}`;
    document.getElementById('btn-save-stash-items').dataset.stashId = stash.id;

    // Reset removals
    pendingStashRemovals = {};

    // Clear dynamic body
    document.getElementById('stash-bulk-add-body').innerHTML = '';
    const currentBody = document.getElementById('stash-current-items-body');
    currentBody.innerHTML = '<tr><td colspan="3" style="text-align: center;">Loading items...</td></tr>';

    openModal('stash-items-modal');

    // Fetch items
    fetch(`https://${GetParentResourceName()}/getStashItems`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({ id: stash.id })
    })
    .then(res => res.json())
    .then(items => {
        currentBody.innerHTML = '';
        if (!items || items.length === 0) {
            currentBody.innerHTML = '<tr><td colspan="3" style="text-align: center; color: var(--text-muted);">Stash is empty</td></tr>';
            return;
        }

        items.forEach(item => {
            const tr = document.createElement('tr');
            tr.id = `stash-item-row-${item.name}`;
            tr.innerHTML = `
                <td><strong>${item.name}</strong><br><span style="font-size: 11px; color: var(--text-muted);">${item.label}</span></td>
                <td>${item.count}</td>
                <td>
                    <button type="button" class="action-btn btn-delete remove-item-trigger" data-name="${item.name}" data-count="${item.count}"><i class="fa-solid fa-trash"></i></button>
                </td>
            `;

            const removeBtn = tr.querySelector('.remove-item-trigger');
            removeBtn.addEventListener('click', () => {
                if (pendingStashRemovals[item.name]) {
                    // Undo removal
                    delete pendingStashRemovals[item.name];
                    tr.style.opacity = '1';
                    tr.style.textDecoration = 'none';
                    removeBtn.innerHTML = '<i class="fa-solid fa-trash"></i>';
                    removeBtn.className = 'action-btn btn-delete remove-item-trigger';
                } else {
                    // Schedule removal
                    pendingStashRemovals[item.name] = item.count;
                    tr.style.opacity = '0.4';
                    tr.style.textDecoration = 'line-through';
                    removeBtn.innerHTML = '<i class="fa-solid fa-rotate-left"></i>';
                    removeBtn.className = 'action-btn btn-edit remove-item-trigger';
                }
            });

            currentBody.appendChild(tr);
        });
    })
    .catch(err => {
        currentBody.innerHTML = '<tr><td colspan="3" style="text-align: center; color: var(--danger);">Failed to load inventory</td></tr>';
        console.error(err);
    });
};


// Event Listeners for coordinates puller
document.getElementById('btn-get-coords').addEventListener('click', () => {
    sendNUIPost('getPlayerCoords', { target: 'create' });
});
document.getElementById('btn-edit-stash-coords').addEventListener('click', () => {
    sendNUIPost('getPlayerCoords', { target: 'edit-stash' });
});
document.getElementById('btn-edit-shop-coords').addEventListener('click', () => {
    sendNUIPost('getPlayerCoords', { target: 'edit-shop' });
});

// Restriction adders
document.getElementById('btn-add-access-row').addEventListener('click', () => createAccessRow(accessRowsContainer));
document.getElementById('btn-edit-stash-add-access').addEventListener('click', () => createAccessRow(editStashAccessRows));
document.getElementById('btn-edit-shop-add-access').addEventListener('click', () => createAccessRow(editShopAccessRows));

// Add Shop item row
document.getElementById('btn-shop-add-item-row').addEventListener('click', () => addShopItemRow());

// Realtime searches
searchStashesInput.addEventListener('input', renderStashes);
searchShopsInput.addEventListener('input', renderShops);

// Form Submit: Create Point
createPointForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const id = document.getElementById('create-id').value.trim();
    const label = document.getElementById('create-label').value.trim();
    const x = parseFloat(document.getElementById('create-x').value);
    const y = parseFloat(document.getElementById('create-y').value);
    const z = parseFloat(document.getElementById('create-z').value);
    
    const access = serializeAccess(accessRowsContainer);
    
    if (currentType === 'stash') {
        const slots = parseInt(document.getElementById('create-slots').value) || 50;
        const weight = parseInt(document.getElementById('create-weight').value) || 100000;
        
        sendNUIPost('saveStash', {
            id, label, slots, weight, access, coords: { x, y, z }
        });
    } else {
        sendNUIPost('saveShop', {
            id, label, access, items: [], coords: { x, y, z }
        });
    }
    
    createPointForm.reset();
    accessRowsContainer.innerHTML = '';
    showToast("Creation submitted successfully!");
});

// Form Submit: Edit Stash
document.getElementById('edit-stash-form').addEventListener('submit', (e) => {
    e.preventDefault();
    const id = document.getElementById('edit-stash-id').value.trim();
    const label = document.getElementById('edit-stash-label').value.trim();
    const slots = parseInt(document.getElementById('edit-stash-slots').value);
    const weight = parseInt(document.getElementById('edit-stash-weight').value);
    const x = parseFloat(document.getElementById('edit-stash-x').value);
    const y = parseFloat(document.getElementById('edit-stash-y').value);
    const z = parseFloat(document.getElementById('edit-stash-z').value);
    const access = serializeAccess(editStashAccessRows);
    
    sendNUIPost('saveStash', {
        id, label, slots, weight, access, coords: { x, y, z }
    });
    
    closeModal('edit-stash-modal');
    showToast("Stash properties saved!");
});

// Form Submit: Edit Shop Details
document.getElementById('edit-shop-form').addEventListener('submit', (e) => {
    e.preventDefault();
    const id = document.getElementById('edit-shop-id').value.trim();
    const label = document.getElementById('edit-shop-label').value.trim();
    const x = parseFloat(document.getElementById('edit-shop-x').value);
    const y = parseFloat(document.getElementById('edit-shop-y').value);
    const z = parseFloat(document.getElementById('edit-shop-z').value);
    const access = serializeAccess(editShopAccessRows);
    
    // Retain previous items when editing details
    const existingShop = dbData.shops[id];
    const items = existingShop ? existingShop.items : [];
    
    sendNUIPost('saveShop', {
        id, label, access, items, coords: { x, y, z }
    });
    
    closeModal('edit-shop-modal');
    showToast("Shop properties saved!");
});

// Form Submit: Save Shop Items
document.getElementById('btn-save-shop-items').addEventListener('click', (e) => {
    const shopId = e.currentTarget.dataset.shopId;
    const itemRows = shopItemsRowsContainer.querySelectorAll('tr');
    
    const items = [];
    let valid = true;
    
    itemRows.forEach(row => {
        const nameInput = row.querySelector('.item-name-input');
        const priceInput = row.querySelector('.item-price-input');
        
        if (nameInput && priceInput) {
            const name = nameInput.value.trim();
            const price = parseInt(priceInput.value);
            
            if (!name || isNaN(price)) {
                valid = false;
                nameInput.style.borderColor = 'var(--danger)';
                priceInput.style.borderColor = 'var(--danger)';
            } else {
                nameInput.style.borderColor = 'var(--border-color)';
                priceInput.style.borderColor = 'var(--border-color)';
                items.push({ name, price });
            }
        }
    });
    
    if (!valid) {
        showToast("Please fill all required item fields!", "error");
        return;
    }
    
    sendNUIPost('updateShopItems', { id: shopId, items });
    closeModal('shop-items-modal');
    showToast("Shop inventory configuration saved!");
});

// Form Submit: Save Stash Items
document.getElementById('btn-stash-add-item-row').addEventListener('click', () => addStashBulkAddRow());

document.getElementById('btn-save-stash-items').addEventListener('click', (e) => {
    const stashId = e.currentTarget.dataset.stashId;
    const bulkRows = document.getElementById('stash-bulk-add-body').querySelectorAll('tr');
    
    const toAdd = [];
    let valid = true;
    
    bulkRows.forEach(row => {
        const nameInput = row.querySelector('.bulk-add-name');
        const countInput = row.querySelector('.bulk-add-count');
        
        if (nameInput && countInput) {
            const name = nameInput.value.trim();
            const count = parseInt(countInput.value);
            
            if (!name || isNaN(count) || count <= 0) {
                valid = false;
                nameInput.style.borderColor = 'var(--danger)';
                countInput.style.borderColor = 'var(--danger)';
            } else {
                nameInput.style.borderColor = 'var(--border-color)';
                countInput.style.borderColor = 'var(--border-color)';
                toAdd.push({ name, count });
            }
        }
    });
    
    if (!valid) {
        showToast("Please fill all required item fields!", "error");
        return;
    }
    
    const toRemove = [];
    Object.keys(pendingStashRemovals).forEach(name => {
        toRemove.push({ name: name, count: pendingStashRemovals[name] });
    });
    
    sendNUIPost('updateStashItems', { id: stashId, toAdd, toRemove });
    closeModal('stash-items-modal');
    showToast("Stash items updated successfully!");
});

// Bind custom confirmation accept button
document.getElementById('btn-confirm-accept').addEventListener('click', () => {
    if (confirmCallback) {
        confirmCallback();
        confirmCallback = null;
    }
    closeModal('confirm-modal');
});

// Exit button
document.getElementById('close-btn').addEventListener('click', () => {
    sendNUIPost('close', {});
});

// Message Listener from Lua Client
window.addEventListener('message', (event) => {
    const data = event.data;
    
    if (data.action === 'openUI') {
        dbData = data.configs;
        appContainer.classList.remove('hidden');
        renderStashes();
        renderShops();
        
        // Reset creating coordinates to placeholder
        document.getElementById('create-x').value = '';
        document.getElementById('create-y').value = '';
        document.getElementById('create-z').value = '';
    } else if (data.action === 'closeUI') {
        appContainer.classList.add('hidden');
        // Hide open modals
        closeModal('edit-stash-modal');
        closeModal('edit-shop-modal');
        closeModal('shop-items-modal');
        closeModal('stash-items-modal');
        closeModal('confirm-modal');
    } else if (data.action === 'setPlayerCoords') {
        const coords = data.coords;
        if (data.target === 'create') {
            document.getElementById('create-x').value = coords.x.toFixed(4);
            document.getElementById('create-y').value = coords.y.toFixed(4);
            document.getElementById('create-z').value = coords.z.toFixed(4);
        } else if (data.target === 'edit-stash') {
            document.getElementById('edit-stash-x').value = coords.x.toFixed(4);
            document.getElementById('edit-stash-y').value = coords.y.toFixed(4);
            document.getElementById('edit-stash-z').value = coords.z.toFixed(4);
        } else if (data.target === 'edit-shop') {
            document.getElementById('edit-shop-x').value = coords.x.toFixed(4);
            document.getElementById('edit-shop-y').value = coords.y.toFixed(4);
            document.getElementById('edit-shop-z').value = coords.z.toFixed(4);
        }
    }
});

// Key listener to close NUI
window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        // If modals are open, close them first
        const modals = ['edit-stash-modal', 'edit-shop-modal', 'shop-items-modal', 'stash-items-modal', 'confirm-modal'];
        let modalClosed = false;
        modals.forEach(id => {
            const modal = document.getElementById(id);
            if (!modal.classList.contains('hidden')) {
                closeModal(id);
                modalClosed = true;
            }
        });
        
        if (!modalClosed) {
            sendNUIPost('close', {});
        }
    }
});

