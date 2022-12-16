-- god i fucking hate lua
function onCreate()
    -- debugPrint("hell")
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
end

function onTimerCompleted(tag, loops, left)
    if string.match(tag, "disable") then
        setNoteColor(tonumber(string.sub(tag, 8)) + 4, "16777215")
    end
end

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'AV' then
        -- debugPrint("AAAAAAAAAA")
		runTimer("disable"..noteData, 5.0, 1)
        setNoteColor(tonumber(noteData + 4), "0")
	end
end