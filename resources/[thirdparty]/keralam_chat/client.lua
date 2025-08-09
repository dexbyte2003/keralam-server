-- Client receives chat messages from server
-- No need to register /say here; server handles it
-- RegisterNetEvent('postMessage')
-- AddEventHandler('postMessage', function(data)
--     TriggerEvent('chatMessage', data.args[1], data.color, data.args[2])
--     SendNUIMessage({
--         type = "chatMessage",
--         author = data.args[1],
--         color = data.color,
--         message = data.args[2]
--     })
-- end)



-- client.lua
RegisterNetEvent('postMessage', function(playerName, job, msg)
    local bannerColor = '#3399ff' -- Default red
    local bannerJob = 'TWITTER'

    if job == 'ambulance' then
        bannerColor = '#ff4d4d'
        bannerJob = 'EMS'
    elseif job == 'police' then
        bannerColor = '#072f54ff'
        bannerJob = 'POLICE'
    elseif job == 'mechanic' then
        bannerColor = '#ffcc00'
        bannerJob = 'MECHANIC'
    else
        bannerColor = '#3399ff'
        bannerJob = 'Twitter'
    end

    -- Send styled message to chat
    TriggerEvent('chat:addMessage', {
        template = [[
            <style>
                @keyframes swipeAndFade {
                    from {
                        transform: translateX(-100%);
                        opacity: 0;
                    }
                    to {
                        transform: translateX(0);
                        opacity: 1;
                    }
                }
            </style>
            <div style="padding: 15px; background-color: {0}; border-radius: 5px; margin-bottom: 7px; animation: swipeAndFade 0.7s forwards;">
                <b>[{1}] {3}</b> <br> <p style="margin-top : 5px;">{2}<p>
            </div>
        ]],
        args = { bannerColor, bannerJob, msg, playerName }
    })
end)
