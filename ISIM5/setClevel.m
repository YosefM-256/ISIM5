function setClevel(level)
    arguments
        level       {mustBeMember(level,[1 0])}
    end
    global sMode;
    mustBeNonempty(sMode);
    mustBeMember(sMode, [1 0]);
    assert(length(sMode) == 5);
    sMode(5) = not(level);
end