window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === 'updateHud') {
        document.getElementById('player-id').textContent = data.playerId;
        document.getElementById('player-name').textContent = data.playerName;
        document.getElementById('player-job').textContent = data.job;
        document.getElementById('job-role').textContent = data.jobRole;
        document.getElementById('money-hand').textContent = data.moneyHand;
        document.getElementById('money-bank').textContent = data.moneyBank;
        document.getElementById('health-fill').style.width = data.health + '%';
        document.getElementById('armor-fill').style.width = data.armor + '%';
        document.getElementById('speed').textContent = data.speed;
    }
});
