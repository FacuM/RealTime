PLUGIN               = nil

SECOND_TICKS         = 20
REAL_TIME_MULTIPLIER = 72

TICK_COUNT           = 0

function Initialize(Plugin)
  Plugin:SetName("RealTime")
  Plugin:SetVersion("1")

  dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")

  PLUGIN = Plugin

  -- Hooks
  cPluginManager:AddHook(cPluginManager.HOOK_TICK, TryUpdateTime)

  LogDebug("Initialized " .. Plugin:GetName() .. " v" .. Plugin:GetVersion())

  return true
end

function LogDebug(message)
  if (DEBUG) then
    LOG(message)
  end
end

function TryUpdateTime()
  if (TICK_COUNT >= ( SECOND_TICKS * (UPDATE_INTERVAL_MILI / 1000) ) ) then
    -- Get parsed time.
    unparsed_time = os.date("%H:%M:%S")

    -- Add an extra delimiter.
    time = unparsed_time .. ":"

    time_seconds = 0
    
    -- Get the time in steps of H, M and S, building a total seconds value.
    INDEX = 1
    for value in time:gmatch("(.-):") do
      if (INDEX == 1) then
        time_seconds = time_seconds + value * 60 * 60
      elseif (INDEX == 2) then
        time_seconds = time_seconds + value * 60
      else
        time_seconds = time_seconds + value
      end

      LogDebug("time_seconds: " .. time_seconds .. " (INDEX = " .. INDEX .. ", value = " .. value)
      INDEX = INDEX + 1
    end

    -- Decrease accuracy to two decimal places.
    TIME_TICKS = string.format("%.2f", (time_seconds / REAL_TIME_MULTIPLIER) * SECOND_TICKS)

    LogDebug("TIME_TICKS: " .. TIME_TICKS)

    -- Set the time across all worlds.
    cRoot:Get():ForEachWorld(
      function (world)
        LogDebug("CURRENT_TICKS: " .. world:GetTimeOfDay())
        world:SetTimeOfDay(TIME_TICKS)
        LogDebug("AFTER_TICKS: " .. world:GetTimeOfDay())
      end
    )

    LOGINFO("The real time is " .. unparsed_time .. ", updating in-game time to " .. TIME_TICKS .. " ticks...")
    TICK_COUNT = 0
  end
  
  TICK_COUNT = TICK_COUNT + 1
end

function OnDisable()
  LogDebug(PLUGIN:GetName() .. " is shutting down...")
end
