---@diagnostic disable: need-check-nil, undefined-field
local Core = {}
local Legacy = GetResourceState('LEGACYCORE'):find('start') and exports['LEGACYCORE']:GetCoreData() or nil
local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil
local QBX = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil
local Shared = require 'utils.utils'

function Core:GetPlayerJob(player)
    if Legacy then
        local Job = Legacy.DATA:GetPlayerJobData(player)?.JobName
        print(Job)
        Shared:GetDebug(Job)
        return Job
    elseif ESX then
        local Job = ESX.GetPlayerFromId(player)?.job?.name or "unemployed"
        Shared:GetDebug(Job)
        return Job
    elseif QBX then
        return exports.qbx_core:GetPlayer(player).PlayerData.job.label
    end
end

function Core:GetPlayerName(player)
    if Legacy then
        local Name = Legacy.DATA:GetPlayerDataBySlot(player)?.playerName

        return string.format("%s", Name)
    elseif ESX then
        local xPlayer = ESX.GetPlayerFromId(player)
        if xPlayer then
            local playerName = string.format("%s %s", xPlayer.get("firstName"), xPlayer.get("lastName"))
            return playerName
        end
    elseif QBX then
        local Data = exports.qbx_core:GetPlayer(player).PlayerData
        return string.format("%s %s", Data.charinfo.firstname, Data.charinfo.lastname)
    end
end

function Core:GetPlayerGroup(player)
    if Legacy then
        return Legacy.DATA:GetPlayerGroup(player)
    elseif ESX then
        local PlayerData = ESX.GetPlayerFromId(player)
        local Group = PlayerData.getGroup()
        return Group
    elseif QBX then
        if IsPlayerAceAllowed(player, 'admin') then
            return 'admin'
        end
    end
end

lib.callback.register('LGF_CHAT:GetPlayerData', function(source)
    local job = Core:GetPlayerJob(source)
    local group = Core:GetPlayerGroup(source)
    local name = Core:GetPlayerName(source)
    return {
        job = job,
        group = group,
        name = name
    }
end)



function Core:SvNotification(source, msg, title, icon)
    TriggerClientEvent('ox_lib:notify', source,
        {
            icon = icon,
            title = title,
            position = 'top-right',
            description = msg,
            duration = 6000
        })
end

return Core
