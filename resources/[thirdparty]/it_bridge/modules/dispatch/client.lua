function it.sendDispatch(disptachData)

    if it.dispatch == Dispatches.NONE then
        it.print.error("No dispatch type set.")
        return
    end

    if it.dispatch == Dispatches.QS then
        TriggerServerEvent('it_bridge:server:sendDispatch', disptachData)
    end

    if it.dispatch == Dispatches.PS then
        TriggerServerEvent('it_bridge:server:sendDispatch', disptachData)
    end

    if it.dispatch == Dispatches.CD then
        local cdDisptachData = {
            job_table = disptachData.jobs,
            coords = vector3(disptachData.coords.x, disptachData.coords.y, disptachData.coords.z),
            title = disptachData.title,
            message = disptachData.message,
            flash = 0,
            unique_id = tostring(math.random(0000000, 9999999)),
            sound = 1,
            blip = {
                sprite = disptachData.blip.sprite,
                scale = disptachData.blip.scale,
                colour = disptachData.blip.colour,
                falshes = disptachData.blip.flashes,
                text = disptachData.blip.text,
                time = disptachData.blip.time,
                radius = disptachData.blip.radius,
            }
        }
        TriggerServerEvent('cd_dispatch:AddNotification', cdDisptachData)
    end

    if it.dispatch == Dispatches.CODEM then
    end

    if it.dispatch == Dispatches.LOVE_SCRIPTS then
        TriggerServerEvent('it_bridge:server:sendDispatch', disptachData)
    end

    if it.dispatch == Dispatches.ORIGEN then
        TriggerServerEvent('it_bridge:server:sendDispatch', disptachData)
    end

    if it.dispatch == Dispatches.PIOTREQ then
        TriggerServerEvent('it_bridge:server:sendDispatch', disptachData)
    end
end

RegisterNetEvent('it_bridge:client:sendDispatch', function(disptachData)
    it.sendDisptach(disptachData)
end)

exports('sendDispatch', function(disptachData)
    it.sendDispatch(disptachData)
end)