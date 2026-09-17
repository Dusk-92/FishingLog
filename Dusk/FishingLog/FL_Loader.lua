-- FishingLog FR7.9 runtime hardening layer.
-- Keeps FL_Main intact while making its chat hook safe across reload orders.

import "Dusk.Common"

-- Validate FL_Options before FL_Main reads it. Keep the automatic FR probe
-- disabled at startup; /fl fr still forces a manual retry when wanted.
local FL79_RawLoad = Turbine.PluginData.Load
Turbine.PluginData.Load = function(scope,key,callback)
    local value = FL79_RawLoad(scope,key,callback)
    if key=="FL_Options" then
        if type(value)~="table" then value={} end
        value.frProbeVersion = 3
    end
    return value
end

-- Capture the chain that existed before FishingLog. FL_Main will install its
-- normal handler on top of this chain.
local FL79_PreviousChat = Turbine.Chat.Received
local FL79_LoadOK,FL79_LoadError = pcall(function()
    import "Dusk.FishingLog.FL_Main"
end)
Turbine.PluginData.Load = FL79_RawLoad
if not FL79_LoadOK then error(FL79_LoadError) end

local FL79_MainChat = Turbine.Chat.Received

-- Generation gate: an old FishingLog wrapper may remain buried under another
-- plugin after an unload/reload. A stale generation forwards directly to the
-- pre-Fishing chain, bypassing its old FishingLog handler, so catches cannot be
-- counted twice and other plugins underneath still receive the event.
FL_ChatGeneration = (FL_ChatGeneration or 0)+1
local FL79_Generation = FL_ChatGeneration

local function FL79_ChatHandler(sender,args)
    if FL79_Generation~=FL_ChatGeneration then
        if FL79_PreviousChat then return FL79_PreviousChat(sender,args) end
        return
    end
    if FL79_MainChat then return FL79_MainChat(sender,args) end
end

FL_PreviousChatHandler = FL79_PreviousChat
FL_ChatHandler = FL79_ChatHandler
Turbine.Chat.Received = FL79_ChatHandler

-- Invalidate this generation even if another plugin currently wraps us.
-- If we are still the top handler, restore the exact chain from before load.
local FL79_OldUnload = Plugins.FishingLog.Unload
Plugins.FishingLog.Unload = function(sender,args)
    if FL79_Generation==FL_ChatGeneration then
        FL_ChatGeneration = FL_ChatGeneration+1
    end
    if Turbine.Chat.Received==FL79_ChatHandler then
        Turbine.Chat.Received = FL79_PreviousChat
    end
    return FL79_OldUnload(sender,args)
end
