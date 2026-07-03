let activeGarageVehicles = [];
let activeAdminGarages = [];
let activeAdminVehicles = [];
let selectedVehicle = null;
let currentGarageType = 'citizen';

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'openGarage') {
        document.getElementById('container').classList.remove('hidden');
        document.getElementById('garage-view').classList.add('active-view');
        document.getElementById('admin-view').classList.remove('active-view');
        document.getElementById('admin-view').classList.add('hidden');
        document.getElementById('garage-view').classList.remove('hidden');

        document.getElementById('garage-title').innerText = data.garageName.toUpperCase();
        currentGarageType = data.type;
        
        // Save target parameters globally for inline additions
        window.isGarageViewAdmin = data.isAdmin || false;
        window.targetGarageViewCitizenid = data.targetCitizenid || null;
        window.targetGarageViewId = data.targetId || null;

        if (window.isGarageViewAdmin) {
            document.getElementById('garage-view-admin-features').classList.remove('hidden');
            document.getElementById('citizen-only-features').classList.add('hidden');
        } else {
            document.getElementById('garage-view-admin-features').classList.add('hidden');
            if (currentGarageType === 'citizen') {
                document.getElementById('citizen-only-features').classList.remove('hidden');
            } else {
                document.getElementById('citizen-only-features').classList.add('hidden');
            }
        }

        activeGarageVehicles = data.vehicles;
        renderVehicleList(activeGarageVehicles);
        resetDetails();
    } else if (data.action === 'openAdmin') {
        document.getElementById('container').classList.remove('hidden');
        document.getElementById('admin-view').classList.add('active-view');
        document.getElementById('garage-view').classList.remove('active-view');
        document.getElementById('garage-view').classList.add('hidden');
        document.getElementById('admin-view').classList.remove('hidden');

        activeAdminGarages = data.garages;
        activeAdminVehicles = data.vehicles;

        renderAdminGarages();
        renderAdminVehicles();
    }
});

function closeUI() {
    document.getElementById('container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({})
    });
}

document.onkeyup = function(data) {
    if (data.key === 'Escape') {
        const editModal = document.getElementById('edit-modal');
        const commModal = document.getElementById('comm-veh-modal');
        
        if (!editModal.classList.contains('hidden')) {
            closeEditModal();
        } else if (!commModal.classList.contains('hidden')) {
            closeCommVehModal();
        } else {
            closeUI();
        }
    }
};

// Render Vehicle List
function renderVehicleList(vehicles) {
    const container = document.getElementById('vehicle-list-container');
    container.innerHTML = '';

    vehicles.forEach(veh => {
        const div = document.createElement('div');
        div.className = 'vehicle-card';
        if (selectedVehicle && selectedVehicle.plate === veh.plate) {
            div.className += ' selected-card';
        }
        
        let statusTag = '';
        if (!veh.isCommunity) {
            if (veh.state === 'In Garage') {
                statusTag = '<span class="card-tag tag-in">In Garage</span>';
            } else {
                statusTag = '<span class="card-tag tag-out">Out</span>';
            }
        } else {
            statusTag = `<span class="card-tag tag-in">Rank ${veh.min_grade}+</span>`;
        }

        div.innerHTML = `
            <h3>${veh.label}</h3>
            <div class="card-plate">${veh.plate}</div>
            ${veh.isShared ? '<span class="card-tag tag-shared">Shared Access</span>' : ''}
            ${statusTag}
        `;
        div.onclick = function() {
            selectVehicle(veh);
            // Highlight selected card
            document.querySelectorAll('.vehicle-card').forEach(el => el.classList.remove('selected-card'));
            div.classList.add('selected-card');
        };
        container.appendChild(div);
    });
}

function selectVehicle(veh) {
    selectedVehicle = veh;
    document.getElementById('select-prompt').classList.add('hidden');
    document.getElementById('details-content').classList.remove('hidden');

    document.getElementById('detail-name').innerText = veh.label;
    document.getElementById('detail-plate').innerText = `PLATE: ${veh.plate}`;

    // Handle spawn button state based on vehicle status
    const spawnBtn = document.querySelector('.spawn-btn');
    const trackBtn = document.querySelector('.track-btn');
    const reclaimBtn = document.querySelector('.reclaim-btn');
    
    // Hide track/reclaim by default
    trackBtn.classList.add('hidden');
    reclaimBtn.classList.add('hidden');

    if (veh.state && (veh.state.includes('Out') || veh.state.includes('out'))) {
        spawnBtn.disabled = true;
        spawnBtn.innerText = "VEHICLE OUT ON ROAD";
        spawnBtn.style.background = "rgba(255, 70, 70, 0.2)";
        spawnBtn.style.color = "rgba(255, 255, 255, 0.4)";
        spawnBtn.style.cursor = "not-allowed";
        spawnBtn.style.border = "1px solid rgba(255, 70, 70, 0.3)";
        
        // Show track or reclaim depending on physical presence state
        if (veh.state.includes('Unsaved')) {
            // Despawned or after restart: Show option to reclaim
            reclaimBtn.classList.remove('hidden');
        } else {
            // Physically present out on road: Show option to mark location
            trackBtn.classList.remove('hidden');
        }
    } else {
        spawnBtn.disabled = false;
        spawnBtn.innerText = "SPAWN VEHICLE";
        spawnBtn.style.background = "linear-gradient(135deg, #3a7bd5, #3a6073)";
        spawnBtn.style.color = "#fff";
        spawnBtn.style.cursor = "pointer";
        spawnBtn.style.border = "none";
    }

    // Stats
    const fuel = veh.fuel || 100;
    const engine = (veh.engine || 1000) / 10;
    const body = (veh.body || 1000) / 10;

    document.getElementById('fuel-bar').style.width = `${fuel}%`;
    document.getElementById('fuel-val').innerText = `${Math.floor(fuel)}%`;

    document.getElementById('engine-bar').style.width = `${engine}%`;
    document.getElementById('engine-val').innerText = `${Math.floor(engine)}%`;

    document.getElementById('body-bar').style.width = `${body}%`;
    document.getElementById('body-val').innerText = `${Math.floor(body)}%`;
}

function resetDetails() {
    selectedVehicle = null;
    document.getElementById('select-prompt').classList.remove('hidden');
    document.getElementById('details-content').classList.add('hidden');
}

function searchVehicles() {
    const q = document.getElementById('veh-search').value.toLowerCase();
    const filtered = activeGarageVehicles.filter(v => v.label.toLowerCase().includes(q) || v.plate.toLowerCase().includes(q));
    renderVehicleList(filtered);
}

function spawnSelected() {
    if (!selectedVehicle) return;
    if (window.isGarageViewAdmin) {
        fetch(`https://${GetParentResourceName()}/adminSpawnVehicle`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8'
            },
            body: JSON.stringify({
                plate: selectedVehicle.plate,
                model: selectedVehicle.model
            })
        });
    } else {
        fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8'
            },
            body: JSON.stringify({
                plate: selectedVehicle.plate,
                model: selectedVehicle.model
            })
        });
    }
    closeUI();
}

function trackSelected() {
    if (!selectedVehicle) return;
    fetch(`https://${GetParentResourceName()}/trackVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            plate: selectedVehicle.plate
        })
    });
    closeUI();
}

function reclaimSelected() {
    if (!selectedVehicle) return;
    fetch(`https://${GetParentResourceName()}/reclaimVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            plate: selectedVehicle.plate
        })
    });
    closeUI();
}

function shareSelected() {
    if (!selectedVehicle) return;
    const id = document.getElementById('share-id').value;
    if (!id) return;
    fetch(`https://${GetParentResourceName()}/shareVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            plate: selectedVehicle.plate,
            targetId: id
        })
    });
    document.getElementById('share-id').value = '';
}

// Admin Logic View Switcher
function switchAdminTab(tab) {
    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active-tab'));
    event.currentTarget.classList.add('active-tab');

    document.getElementById('admin-creator-tab').classList.add('hidden');
    document.getElementById('admin-list-tab').classList.add('hidden');
    document.getElementById('admin-vehicles-tab').classList.add('hidden');
    document.getElementById('admin-addvehicle-tab').classList.add('hidden');

    if (tab === 'creator') {
        document.getElementById('admin-creator-tab').classList.remove('hidden');
    } else if (tab === 'list') {
        document.getElementById('admin-list-tab').classList.remove('hidden');
        renderAdminGarages();
    } else if (tab === 'vehicles') {
        document.getElementById('admin-vehicles-tab').classList.remove('hidden');
        renderAdminVehicles();
    } else if (tab === 'addvehicle') {
        document.getElementById('admin-addvehicle-tab').classList.remove('hidden');
    }
}

function toggleJobGangInput() {
    const type = document.getElementById('g-type').value;
    const jobGroup = document.getElementById('job-gang-group');
    const gradeGroup = document.getElementById('grade-group');
    const label = document.getElementById('job-gang-label');

    if (type === 'job') {
        jobGroup.classList.remove('hidden');
        gradeGroup.classList.remove('hidden');
        label.innerText = "Job Name";
    } else if (type === 'gang') {
        jobGroup.classList.remove('hidden');
        gradeGroup.classList.remove('hidden');
        label.innerText = "Gang Name";
    } else {
        jobGroup.classList.add('hidden');
        gradeGroup.classList.add('hidden');
    }
}

function setCoords(type) {
    fetch(`https://${GetParentResourceName()}/adminSetCoords`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ type: type })
    });
}

function createGarage() {
    const name = document.getElementById('g-name').value;
    const label = document.getElementById('g-label').value;
    const type = document.getElementById('g-type').value;
    const job_gang = document.getElementById('g-jobgang').value;
    const grade = document.getElementById('g-grade').value;

    fetch(`https://${GetParentResourceName()}/createGarage`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            name: name,
            label: label,
            type: type,
            job_gang_name: job_gang,
            min_grade: grade
        })
    });
}

function renderAdminGarages() {
    const tbody = document.getElementById('admin-garages-table');
    tbody.innerHTML = '';

    activeAdminGarages.forEach(g => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${g.name}</td>
            <td>${g.label}</td>
            <td>${g.type.toUpperCase()}</td>
            <td>${g.job_gang_name ? `${g.job_gang_name} (Min Grade: ${g.min_grade})` : 'None'}</td>
            <td>
                ${g.type !== 'citizen' ? `<button class="btn-small btn-success" onclick="openCommVehModal('${g.name}')">Add Fleet</button>` : ''}
                <button class="btn-small btn-danger" onclick="deleteGarage('${g.name}')">Delete</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function deleteGarage(name) {
    fetch(`https://${GetParentResourceName()}/deleteGarage`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ name: name })
    });
    activeAdminGarages = activeAdminGarages.filter(g => g.name !== name);
    renderAdminGarages();
}

function renderAdminVehicles() {
    const tbody = document.getElementById('admin-vehicles-table');
    tbody.innerHTML = '';

    activeAdminVehicles.forEach(v => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${v.plate}</td>
            <td>${v.citizenid}</td>
            <td>${v.model}</td>
            <td>${v.state}</td>
            <td>
                <button class="btn-small btn-success" onclick="adminSpawnVehicle('${v.plate}', '${v.model}')">Spawn</button>
                <button class="btn-small" onclick="openEditModal('${v.plate}', '${v.state}', '${v.fuel}')">Manage</button>
                <button class="btn-small btn-danger" onclick="adminDeleteVehicle('${v.plate}')">Delete</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function adminSpawnVehicle(plate, model) {
    fetch(`https://${GetParentResourceName()}/adminSpawnVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ plate: plate, model: model })
    });
    closeUI();
}

function searchAdminVehicles() {
    const q = document.getElementById('admin-veh-search').value.toLowerCase();
    const filtered = activeAdminVehicles.filter(v => 
        (v.plate && v.plate.toLowerCase().includes(q)) || 
        (v.citizenid && v.citizenid.toLowerCase().includes(q)) || 
        (v.model && v.model.toLowerCase().includes(q))
    );
    
    const tbody = document.getElementById('admin-vehicles-table');
    tbody.innerHTML = '';
    filtered.forEach(v => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${v.plate}</td>
            <td>${v.citizenid}</td>
            <td>${v.model}</td>
            <td>${v.state}</td>
            <td>
                <button class="btn-small btn-success" onclick="adminSpawnVehicle('${v.plate}', '${v.model}')">Spawn</button>
                <button class="btn-small" onclick="openEditModal('${v.plate}', '${v.state}', '${v.fuel}')">Manage</button>
                <button class="btn-small btn-danger" onclick="adminDeleteVehicle('${v.plate}')">Delete</button>
            </td>
        `;
        tbody.appendChild(tr);
    });
}

function toggleAddVehicleType() {
    const val = document.getElementById('av-ident-type').value;
    if (val === 'citizenid') {
        document.getElementById('av-citizenid-group').classList.remove('hidden');
        document.getElementById('av-playerid-group').classList.add('hidden');
    } else {
        document.getElementById('av-citizenid-group').classList.add('hidden');
        document.getElementById('av-playerid-group').classList.remove('hidden');
    }
}

let pendingVehicleData = null;

function adminAddVehicle() {
    const identType = document.getElementById('av-ident-type').value;
    const cid = document.getElementById('av-citizenid').value;
    const pid = document.getElementById('av-playerid').value;
    const model = document.getElementById('av-model').value;
    const plate = document.getElementById('av-plate').value;

    if (identType === 'citizenid' && !cid) return;
    if (identType === 'playerid' && !pid) return;
    if (!model) return;

    pendingVehicleData = {
        identType: identType,
        citizenid: cid,
        playerid: pid,
        model: model,
        plate: plate
    };

    // Trigger NUI request to get target player details
    fetch(`https://${GetParentResourceName()}/adminGetPlayerName`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            identType: identType,
            citizenid: cid,
            playerid: pid
        })
    }).then(res => res.json()).then(data => {
        if (data.name) {
            document.getElementById('confirm-msg').innerText = `Are you sure you want to add vehicle model "${model.toUpperCase()}" to player "${data.name}" (CitizenID: ${data.citizenid})?`;
            document.getElementById('confirm-modal').classList.remove('hidden');
        } else {
            // Player not online or not found, fall back to confirmation with direct input
            document.getElementById('confirm-msg').innerText = `Player not online or resolved. Add vehicle model "${model.toUpperCase()}" to CitizenID "${data.citizenid || cid}" directly?`;
            document.getElementById('confirm-modal').classList.remove('hidden');
        }
    });
}

function confirmAddVehicle() {
    if (!pendingVehicleData) return;
    fetch(`https://${GetParentResourceName()}/adminAddVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(pendingVehicleData)
    });
    
    document.getElementById('av-citizenid').value = '';
    document.getElementById('av-playerid').value = '';
    document.getElementById('av-model').value = '';
    document.getElementById('av-plate').value = '';
    closeConfirmModal();
}

function closeConfirmModal() {
    document.getElementById('confirm-modal').classList.add('hidden');
    pendingVehicleData = null;
}

function adminDeleteVehicle(plate) {
    fetch(`https://${GetParentResourceName()}/adminDeleteVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ plate: plate })
    });
    activeAdminVehicles = activeAdminVehicles.filter(v => v.plate !== plate);
    renderAdminVehicles();
}

// Edit Modal Functions
function openEditModal(plate, state, fuel) {
    window.currentEditingOriginalPlate = plate;
    document.getElementById('edit-plate').value = plate;
    document.getElementById('edit-state').value = state === 'In Garage' ? '1' : '0';
    document.getElementById('edit-fuel').value = Math.floor(parseFloat(fuel) || 100);
    document.getElementById('edit-modal').classList.remove('hidden');
}

function closeEditModal() {
    document.getElementById('edit-modal').classList.add('hidden');
}

function saveVehicleEdits() {
    const newPlate = document.getElementById('edit-plate').value;
    const state = document.getElementById('edit-state').value;
    const fuel = document.getElementById('edit-fuel').value;

    fetch(`https://${GetParentResourceName()}/adminManageVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            originalPlate: window.currentEditingOriginalPlate,
            plate: newPlate,
            state: state,
            fuel: fuel
        })
    });

    // Update UI state locally for Admin View
    activeAdminVehicles.forEach(v => {
        if (v.plate === window.currentEditingOriginalPlate) {
            v.plate = newPlate;
            v.state = (state === '1' ? 'In Garage' : 'Out on Road');
            v.fuel = fuel;
        }
    });
    renderAdminVehicles();

    // Update UI state locally for Garage View (if open)
    activeGarageVehicles.forEach(v => {
        if (v.plate === window.currentEditingOriginalPlate) {
            v.plate = newPlate;
            v.state = (state === '1' ? 'In Garage' : 'Out on Road');
            v.fuel = fuel;
        }
    });
    renderVehicleList(activeGarageVehicles);

    closeEditModal();
}

// Community Vehicle Modal
let currentTargetCommunityGarage = '';
function openCommVehModal(garageName) {
    currentTargetCommunityGarage = garageName;
    document.getElementById('comm-modal-title').innerText = `Configure Fleet: ${garageName.toUpperCase()}`;
    document.getElementById('comm-veh-modal').classList.remove('hidden');
    refreshCommunityFleetList();
}

function closeCommVehModal() {
    document.getElementById('comm-veh-modal').classList.add('hidden');
}

function refreshCommunityFleetList() {
    fetch(`https://${GetParentResourceName()}/adminGetCommunityVehicles`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ garageName: currentTargetCommunityGarage })
    }).then(res => res.json()).then(data => {
        const tbody = document.getElementById('comm-fleet-table');
        tbody.innerHTML = '';
        window.currentCommunityVehicles = data;
        data.forEach((v, index) => {
            const tr = document.createElement('tr');
            tr.innerHTML = `
                <td>${v.model}</td>
                <td>${v.label}</td>
                <td>Rank ${v.min_grade}+</td>
                <td>${v.plate_type ? v.plate_type.toUpperCase() : 'STATIC'}</td>
                <td>${v.custom_plate ? v.custom_plate.toUpperCase() : 'NONE'}</td>
                <td>
                    <button class="btn-small btn-success" onclick="openEditCommVehModalByIndex(${index})">Edit</button>
                    <button class="btn-small btn-danger" onclick="deleteCommunityVehicle(${v.id})">Delete</button>
                </td>
            `;
            tbody.appendChild(tr);
        });
    });
}

let activeEditingCommVehicle = null;

function openEditCommVehModalByIndex(index) {
    const vehicle = window.currentCommunityVehicles && window.currentCommunityVehicles[index];
    if (!vehicle) return;
    activeEditingCommVehicle = vehicle;
    document.getElementById('edit-cv-model').value = vehicle.model;
    document.getElementById('edit-cv-label').value = vehicle.label;
    document.getElementById('edit-cv-grade').value = vehicle.min_grade;
    document.getElementById('edit-cv-platetype').value = vehicle.plate_type || 'static';
    
    if (vehicle.plate_type === 'custom') {
        document.getElementById('edit-cv-customplate-group').classList.remove('hidden');
        document.getElementById('edit-cv-customplate').value = vehicle.custom_plate || '';
    } else {
        document.getElementById('edit-cv-customplate-group').classList.add('hidden');
    }
    
    document.getElementById('edit-comm-veh-modal').classList.remove('hidden');
}

function closeEditCommVehModal() {
    document.getElementById('edit-comm-veh-modal').classList.add('hidden');
    activeEditingCommVehicle = null;
}

function toggleEditCommunityPlateInput() {
    const val = document.getElementById('edit-cv-platetype').value;
    if (val === 'custom') {
        document.getElementById('edit-cv-customplate-group').classList.remove('hidden');
    } else {
        document.getElementById('edit-cv-customplate-group').classList.add('hidden');
    }
}

function saveCommunityVehicleEdits() {
    if (!activeEditingCommVehicle) return;
    
    const label = document.getElementById('edit-cv-label').value;
    const grade = document.getElementById('edit-cv-grade').value;
    const platetype = document.getElementById('edit-cv-platetype').value;
    const customplate = document.getElementById('edit-cv-customplate').value;

    fetch(`https://${GetParentResourceName()}/adminManageCommunityVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            id: activeEditingCommVehicle.id,
            label: label,
            min_grade: grade,
            plate_type: platetype,
            custom_plate: customplate
        })
    }).then(() => {
        refreshCommunityFleetList();
        closeEditCommVehModal();
    });
}

function deleteCommunityVehicle(id) {
    fetch(`https://${GetParentResourceName()}/adminDeleteCommunityVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({ id: id })
    }).then(() => {
        refreshCommunityFleetList();
    });
}

function toggleCommunityPlateInput() {
    const val = document.getElementById('cv-platetype').value;
    if (val === 'custom') {
        document.getElementById('cv-customplate-group').classList.remove('hidden');
    } else {
        document.getElementById('cv-customplate-group').classList.add('hidden');
    }
}

function addCommunityVehicle() {
    const model = document.getElementById('cv-model').value;
    const label = document.getElementById('cv-label').value;
    const grade = document.getElementById('cv-grade').value;
    const platetype = document.getElementById('cv-platetype').value;
    const customplate = document.getElementById('cv-customplate').value;

    fetch(`https://${GetParentResourceName()}/adminAddCommunityVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            garage_name: currentTargetCommunityGarage,
            model: model,
            label: label,
            min_grade: grade,
            plate_type: platetype,
            custom_plate: customplate
        })
    }).then(() => {
        refreshCommunityFleetList();
    });

    document.getElementById('cv-model').value = '';
    document.getElementById('cv-label').value = '';
    document.getElementById('cv-grade').value = '0';
    document.getElementById('cv-customplate').value = '';
    document.getElementById('cv-customplate-group').classList.add('hidden');
    document.getElementById('cv-platetype').value = 'static';
}

// Admin Player View Action Handlers
function adminManageSelected() {
    if (!selectedVehicle) return;
    openEditModal(selectedVehicle.plate, selectedVehicle.state, selectedVehicle.fuel);
}

function adminDeleteSelected() {
    if (!selectedVehicle) return;
    adminDeleteVehicle(selectedVehicle.plate);
    // Remove from local garage view list
    activeGarageVehicles = activeGarageVehicles.filter(v => v.plate !== selectedVehicle.plate);
    renderVehicleList(activeGarageVehicles);
    resetDetails();
}

function adminAddVehicleToThis() {
    const model = document.getElementById('admin-add-model').value;
    const plate = document.getElementById('admin-add-plate').value;
    if (!model || !window.targetGarageViewCitizenid) return;

    pendingVehicleData = {
        identType: 'citizenid',
        citizenid: window.targetGarageViewCitizenid,
        model: model,
        plate: plate
    };

    fetch(`https://${GetParentResourceName()}/adminGetPlayerName`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify({
            identType: 'citizenid',
            citizenid: window.targetGarageViewCitizenid
        })
    }).then(res => res.json()).then(data => {
        const name = data.name || "Offline Owner";
        document.getElementById('confirm-msg').innerText = `Are you sure you want to add vehicle model "${model.toUpperCase()}" to player "${name}" (CitizenID: ${window.targetGarageViewCitizenid})?`;
        document.getElementById('confirm-modal').classList.remove('hidden');
    });

    document.getElementById('admin-add-model').value = '';
    document.getElementById('admin-add-plate').value = '';
}

