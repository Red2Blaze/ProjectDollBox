/*
Name: ProjectDollBox
Creator: Red2Blaze
Date: June.4.2023
*/

key user;
string desc = "";
integer status;

key requestId; 

float checkTime = 15;

doStatus (integer statusActive)
{
    if (!statusActive)
    {
        llSetColor (<0.5,0.5,0.5>, ALL_SIDES);
        llSetAlpha (1.0, ALL_SIDES);
        return;
    }
    if (statusActive == 1)
    {
        llSetAlpha (0.0, ALL_SIDES);
        return;
    }
    if (statusActive == 2)
    {
        llSetColor (<1.0,1.0,1.0>, ALL_SIDES);
        llSetAlpha (1.0, ALL_SIDES);
        return;
    }
}

list GetSitTarget(integer prim, key av)
{
 
    vector tp = llGetAgentSize(av);
    if (tp)
    {
        list details = llGetLinkPrimitiveParams(prim, [PRIM_POSITION, PRIM_ROTATION]) + llGetObjectDetails(av, [OBJECT_POS, OBJECT_ROT]);
        rotation f = llList2Rot(details, 1);
        rotation r = llList2Rot(details, 3) / f;
        float fAdjust = ((((0.008906 * tp.z) + -0.049831) * tp.z) + 0.088967) * tp.z;
        return [((llList2Vector(details, 2) - llList2Vector(details, 0)) / f) + (llRot2Up(r) * fAdjust) - <0.0, 0.0, 0.4>, r];
    }
    return [];
}

default
{
    state_entry()
    {
        desc = llGetObjectDesc();
        user = desc;
        if (desc == "" || desc == "(No Description)")
            user = llGetOwner();
        requestId = llRequestAgentData( user, DATA_ONLINE);
        llSetTimerEvent (checkTime);
        list sitTargetGet = GetSitTarget (LINK_THIS, user); 
        llSitTarget (llList2Vector (sitTargetGet, 0), llList2Rot (sitTargetGet, 1));
    }

    timer()
    {
        requestId = llRequestAgentData( user, DATA_ONLINE);
    }

    dataserver(key queryid, string data)
    {
        if (requestId != queryid)
            return;
        if ( data == "1" ) 
        {
            if (!status)
                status = TRUE;
        }
        else if (data == "0")
        {
            status = FALSE;
        }
        doStatus (status);
        
        if (llGetObjectDesc() != desc)
            llResetScript();
    }
    
    changed (integer change)
    {
        if (change & CHANGED_LINK)
        {
            key sitter = llAvatarOnSitTarget();
            if (sitter == NULL_KEY)
                return;
            if (sitter != user)
            {
                llUnSit(sitter);
                return;
            }
            status = 2;
            doStatus (status);
        }
    }
}
