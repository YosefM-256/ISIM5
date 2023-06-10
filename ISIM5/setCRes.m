function setCRes(CResNum)
    mustBeMember(CResNum,[0 1]);
    global sMode; 
    mustBeNonempty(sMode);
    sMode(3) = CResNum;
end