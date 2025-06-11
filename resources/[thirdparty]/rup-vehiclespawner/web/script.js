let vehicleModels = {};
let currentCategory = null;

document.addEventListener('DOMContentLoaded', () => {
   const searchInput = document.getElementById('searchInput');

   window.addEventListener('message', (event) => {
      if (event.data.type === 'setVehicleModels') {
         vehicleModels = event.data.models;
         populateCategories();
         const firstCategory = document.querySelector('.category-item');
         if (firstCategory) firstCategory.click();
      }

      if (event.data.action === "openUI") {
         openUI();
      }
   });

   document.addEventListener('keydown', (event) => {
      if (event.key === 'Escape') closeUI();
   });

   searchInput.addEventListener('input', (e) => {
      const searchTerm = e.target.value.toLowerCase();
      if (searchTerm.length > 0) {
         filterVehicles(searchTerm);
      } else if (currentCategory) {
         if (currentCategory === 'All') showAllVehicles();
         else showVehiclesInCategory(currentCategory);
      }
   });
});

// FiveM Open UI
function openUI() {
   document.body.style.display = 'block';
   const dashboard = document.querySelector('.dashboard-container');
   dashboard.classList.add('visible');
   void dashboard.offsetHeight;
}

// FiveM Close UI
function closeUI() {
   const dashboard = document.querySelector('.dashboard-container');
   dashboard.classList.remove('visible');
   document.body.style.display = 'none';
   fetch(`https://${GetParentResourceName()}/closeUI`, {
      method: 'POST',
      headers: {
         'Content-Type': 'application/json'
      },
   });
}

function populateCategories() {
   const categoryList = document.getElementById('category-list');
   categoryList.innerHTML = '';

   const categoryIcons = {
      'All': 'fa-layer-group',
      'Motorcycles': 'fa-motorcycle',
      'Helicopters': 'fa-helicopter',
      'Planes': 'fa-plane',
      'Boats': 'fa-ship',
      'Trains': 'fa-train',
      'Cycles': 'fa-bicycle',
   };

   const sortedCategories = ['All', ...Object.keys(vehicleModels).sort((a, b) => a.localeCompare(b))];

   sortedCategories.forEach(category => {
      if (category === 'All' || vehicleModels[category]) {
         const categoryItem = document.createElement('div');
         categoryItem.className = 'category-item';
         categoryItem.innerHTML = `
                <i class="fas ${categoryIcons[category] || 'fa-car'}"></i>
                ${category}
            `;
         categoryItem.addEventListener('click', () => {
            currentCategory = category;
            document.querySelectorAll('.category-item').forEach(el => el.classList.remove('active'));
            categoryItem.classList.add('active');
            document.getElementById('searchInput').value = '';
            if (category === 'All') showAllVehicles();
            else showVehiclesInCategory(category);
         });
         categoryList.appendChild(categoryItem);
      }
   });
}

function showAllVehicles() {
   const vehicleList = document.getElementById('vehicle-list');
   vehicleList.style.opacity = '0';
   setTimeout(() => {
      vehicleList.innerHTML = '';
      const allVehicles = Object.entries(vehicleModels).flatMap(([category, vehicles]) =>
         vehicles.map(vehicle => ({
            ...vehicle,
            category: category
         }))
      );
      const sortedVehicles = allVehicles.sort((a, b) => a.model.localeCompare(b.model));

      document.getElementById('current-category').innerHTML = `
            <i class="fas fa-layer-group"></i>
            <span>All Vehicles</span>
        `;
      updateResultsCount(sortedVehicles.length);

      sortedVehicles.forEach(vehicle => {
         const card = document.createElement('div');
         card.className = 'vehicle-card';
         card.innerHTML = `
            <div class="vehicle-header">
               <div class="vehicle-name">${vehicle.model}</div>
               <div class="vehicle-category">${vehicle.category}</div>
            </div>
            <div class="vehicle-image-container">
               <img src="https://docs.fivem.net/vehicles/${vehicle.model}.webp" 
                  class="vehicle-image" 
                  alt="${vehicle.model}"
                  loading="lazy"
                  onerror="this.onerror=null; this.src='./images/${vehicle.model}.png'; this.onerror=() => {this.src='./images/fallback.png'}">
            </div>
            <div class="vehicle-content">
               <div class="vehicle-actions">
                  <button class="spawn-btn" onclick="spawnVehicle('${vehicle.model}')">
                  <i class="fas fa-car"></i> Spawn
                  </button>
               </div>
            </div>
            `;
         vehicleList.appendChild(card);
      });
      void vehicleList.offsetHeight;
      vehicleList.style.opacity = '1';
   }, 50);
}

// Top right of UI, Displays how many vehicles in that category
function updateResultsCount(count) {
   document.getElementById('results-count').textContent = `${count} vehicles available`;
}

function showVehiclesInCategory(category) {
   const vehicleList = document.getElementById('vehicle-list');
   vehicleList.style.opacity = '0';
   setTimeout(() => {
      vehicleList.innerHTML = '';
      const sortedVehicles = [...vehicleModels[category]].map(vehicle => ({
         ...vehicle,
         category: category
      }));

      document.getElementById('current-category').innerHTML = `
            <i class="fas fa-tag"></i>
            <span>${category}</span>
        `;
      updateResultsCount(sortedVehicles.length);

      sortedVehicles.forEach(vehicle => {
         const card = document.createElement('div');
         card.className = 'vehicle-card';
         card.innerHTML = `
            <div class="vehicle-header">
               <div class="vehicle-name">${vehicle.model}</div>
               <div class="vehicle-category">${vehicle.category}</div>
            </div>
            <div class="vehicle-image-container">
               <img src="https://docs.fivem.net/vehicles/${vehicle.model}.webp" 
                  class="vehicle-image" 
                  alt="${vehicle.model}"
                  loading="lazy"
                  onerror="this.onerror=null; this.src='./images/${vehicle.model}.png'; this.onerror=() => {this.src='./images/fallback.png'}">
            </div>
            <div class="vehicle-content">
               <div class="vehicle-actions">
                  <button class="spawn-btn" onclick="spawnVehicle('${vehicle.model}')">
                  <i class="fas fa-car"></i> Spawn
                  </button>
               </div>
            </div>
            `;
         vehicleList.appendChild(card);
      });
      void vehicleList.offsetHeight;
      vehicleList.style.opacity = '1';
   }, 50);
}

// Spawn vehicle, see client.lua for event
function spawnVehicle(model) {
   fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
      method: 'POST',
      headers: {
         'Content-Type': 'application/json'
      },
      body: JSON.stringify({
         model: model
      }),
   });
   closeUI();
}

function filterVehicles(searchTerm) {
   const vehicleList = document.getElementById('vehicle-list');
   vehicleList.style.opacity = '0';
   setTimeout(() => {
      vehicleList.innerHTML = '';
      const allVehicles = Object.entries(vehicleModels).flatMap(([category, vehicles]) =>
         vehicles.map(vehicle => ({ ...vehicle, category: category})));

      const filteredVehicles = allVehicles
         .filter(vehicle => vehicle.model.toLowerCase().includes(searchTerm))
         .sort((a, b) => a.model.localeCompare(b.model));

      if (currentCategory === 'All') {
         filteredVehicles.forEach(vehicle => {
            const card = document.createElement('div');
            card.className = 'vehicle-card';
            card.innerHTML = `
                <div class="vehicle-header">
                   <div class="vehicle-name">${vehicle.model}</div>
                   <div class="vehicle-category">${vehicle.category}</div>
                </div>
                <div class="vehicle-image-container">
                   <img src="https://docs.fivem.net/vehicles/${vehicle.model}.webp" 
                      class="vehicle-image" 
                      alt="${vehicle.model}"
                      loading="lazy"
                      onerror="this.onerror=null; this.src='./images/${vehicle.model}.png'; this.onerror=() => {this.src='./images/fallback.png'}">
                </div>
                <div class="vehicle-content">
                   <div class="vehicle-actions">
                      <button class="spawn-btn" onclick="spawnVehicle('${vehicle.model}')">
                      <i class="fas fa-car"></i> Spawn
                      </button>
                   </div>
                </div>
                `;
            vehicleList.appendChild(card);
         });
      } else {
         const filtered = {};
         Object.keys(vehicleModels).forEach(category => {
            filtered[category] = vehicleModels[category]
               .filter(vehicle => vehicle.model.toLowerCase().includes(searchTerm))
               .sort((a, b) => a.model.localeCompare(b.model))
               .map(vehicle => ({ ...vehicle, category: category}));
         });

         Object.entries(filtered).forEach(([category, vehicles]) => {
            if (vehicles.length === 0) return;
            vehicles.forEach(vehicle => {
               const card = document.createElement('div');
               card.className = 'vehicle-card';
               card.innerHTML = `
                    <div class="vehicle-header">
                       <div class="vehicle-name">${vehicle.model}</div>
                       <div class="vehicle-category">${vehicle.category}</div>
                    </div>
                    <div class="vehicle-image-container">
                       <img src="https://docs.fivem.net/vehicles/${vehicle.model}.webp" 
                          class="vehicle-image" 
                          alt="${vehicle.model}"
                          loading="lazy"
                          onerror="this.onerror=null; this.src='./images/${vehicle.model}.png'; this.onerror=() => {this.src='./images/fallback.png'}">
                    </div>
                    <div class="vehicle-content">
                       <div class="vehicle-actions">
                          <button class="spawn-btn" onclick="spawnVehicle('${vehicle.model}')">
                          <i class="fas fa-car"></i> Spawn
                          </button>
                       </div>
                    </div>
                    `;
               vehicleList.appendChild(card);
            });
         });
      }

      document.getElementById('current-category').innerHTML = `
            <i class="fas fa-search"></i>
            <span>Search Results</span>
        `;
      updateResultsCount(filteredVehicles.length);
      void vehicleList.offsetHeight;
      vehicleList.style.opacity = '1';
   }, 50);
}