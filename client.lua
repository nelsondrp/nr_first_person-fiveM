local cam = GetRenderingCam()
local playerPed = GetPlayerPed(-1)
local boneHead = 31086
local combatMode = false
local keyV = 0


--TODO::
-- + Aumentar FOV da camera no veiculo (provavelmente não é possível)
-- + Utilizar fade in/ fade out de uma forma mais interessante para ragdoll
-- + Corrigir rotation da camera quando entra e sai de Combat Mode
-- + Corrigir movimentação lateral e para tras em primeira pessoa
-- + Permtir configuração da FOV pelo usuario (provavelmente nao é possivel)
-- + Fadeout quando player morrer

------------ ATUALIZAÇÂO DO COMBAT MODE ---------------

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if IsControlJustReleased(0, keyV) then
            combatMode = not combatMode
        end

        if IsPedArmed(playerPed, 4 or 2) then
            EnableCrosshairThisFrame()
        end
    end
end)


------------ PERDA DE CONSCIENCIA COM RAGDOLL ---------------
--local inRagdoll = false
--Citizen.CreateThread(function()
--    while true do
--        Citizen.Wait(1)
--        if IsPedRagdoll(playerPed) then
--            DoScreenFadeOut(0)
--            inRagdoll = true
--        elseif inRagdoll then -- ta meio zoado, nao vou mexer sem poder testar
--            Citizen.Wait(2000)
--            DoScreenFadeIn(3000)
--        end
--    end
--end)

------------ ATUALIZAÇÂO DOS MODOS DE CAMERA (ON_FOOT/DRIVING/COMBAT) ---------------
Citizen.CreateThread(function()
    createAndActivateCamera()

    print("working-")
    while true do
        Citizen.Wait(1)
        if (IsPedOnFoot(playerPed)) and not combatMode then
            renderScriptCam(true)
            computeCameraRotation()
            blockDefaultFP()
        else
            renderScriptCam(false)
           -- SetCamFov(,130.0) -- não funciona
           -- Coloca em primeira pessoa padrão do GTA quando o player entra em todos tipos de veiculos ou armas montadas
           -- Ou se o jogador entra em "modo de combate", TECLA V para entrar em combate
            SetCamViewModeForContext(0, 4)
            SetCamViewModeForContext(1, 4)
            SetCamViewModeForContext(2, 4)
            SetCamViewModeForContext(3, 4)
            SetCamViewModeForContext(4, 4)
            SetCamViewModeForContext(5, 4)
            SetCamViewModeForContext(6, 4)
            SetCamViewModeForContext(7, 4)
        end
    end
end)

function createAndActivateCamera()
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov() * 1.3)

    -- Números delicados, mexa a vontade para alterar o posicionamento da camera
    -- mas mexa aos poucos e lembre dos valores padrão, muito teste manual pra chegar nesses valores rs
    local yOffsetAdjustment = 0.12 -- Front/back
    local zOffsetAdjustment = 0.05 -- Up/down

    AttachCamToPedBone(cam , playerPed , boneHead , 0.0, yOffsetAdjustment, zOffsetAdjustment, true)
    SetCamActive(cam, true)
end

local offsetRotX = 0
local offsetRotZ = 0
local rotation = 0

-- Nome autodescritivo, faz a camera acompanhar o mouse
function computeCameraRotation()
    DisableControlAction(1,1,true)
    DisableControlAction(1,2,true)

    offsetRotX = offsetRotX - GetDisabledControlNormal(1, 2) * 10.0
    offsetRotZ = offsetRotZ - GetDisabledControlNormal(1, 1) * 10.0

    if(offsetRotX <= -65.0) then
        offsetRotX = -65.0
    end
    if(offsetRotX >= 50.0) then
        offsetRotX = 50.0
    end

    rotation = GetCamRot(cam, 2)
    SetEntityHeading(playerPed, rotation.z)
    SetCamRot(cam, offsetRotX, GetEntityRotation(playerPed, 2).y, offsetRotZ, 2)
end


-- Quando o jogador sai do veiculo e em outras situaçoões adversas
-- o game processa ainda uma quantidade de frames em primeira pessoa padrão do game, o que
-- altera o eixo do personagem quando ele entra na primeira pessoa do mod, deixando a movimentação confusa
-- Essa função aconteça chamada quando a camera do mod é processada impede que isso aconteça
function blockDefaultFP()
    if(GetFollowPedCamViewMode() ~= 0)then
        SetFollowPedCamViewMode(0)
    end
end

-- Desativa a camera do script quando o jogador entra em veiculos ou combat mode (tecla v)
function renderScriptCam(active)
    if(active) then
        RenderScriptCams(true, false, 0, false, false)
    else
        RenderScriptCams(false, false, 0, false, false)
    end
end
