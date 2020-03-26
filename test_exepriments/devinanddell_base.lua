local _mpfObjects = {
  baseGameContainer = nil;
  freespinsContainer = nil;
  mpf_ReelSet = nil;
  game1Multipliers = {};
  game2Multipliers = {};
  game2Multiplier_3x = nil;
  game2Multiplier_4x = nil;
  game2Multiplier_5x = nil;
  game2MultiplierText = nil;
  game1FreeSpinMultiplierText = nil;
  game2FreeSpinMultiplierText = nil;
  treespinCounter = nil;
  devinObject = nil;
  dellObject = nil;
  meowtiplier = nil;
  introDialog = nil;
  introDialogClose = nil;
  game1MultiplierGroupFS = nil;
  game2MultiplierGroupFS = nil;
  paylines_G1 = nil;
  paylines_G2 = nil;
}
local _showingGame1Multiplier = false;
local _showingGame2Multiplier = false;
local _symbolsAtIndexPosition = {};
local _ge2GameManager = nil;
local _stopGame1WildFXOnSpinStart = false;
local _introPlayed = false;

function HasFreeSpinsRemaining()
  return ((GetWritableModelElement("FreeSpinsRemaining") ~= nil and
      GetWritableModelElement("FreeSpinsRemaining") > 0)) && true;
end

function IsRecovery()
  local recovery = false;
  if (EvaluateTrigger("PickBonusInProgress") or EvaluateTrigger("FreeSpinState")) then
    recovery = true;
  end
  return recovery;
end

function GetMPFObjects()
  return _mpfObjects;
end

function InitMPFObjects()
  _mpfObjects.baseGameContainer = GetObjectWithTag("BaseGameContainer");
  _mpfObjects.freespinsContainer = GetObjectWithTag("FreespinsContainer");
  _mpfObjects.mpf_ReelSet = GetObjectWithTag("MPF_ReelSet");
  _mpfObjects.game1FreeSpinMultiplierText = GetObjectWithTag("Game1MultiplierText_FS");
  _mpfObjects.game2FreeSpinMultiplierText = GetObjectWithTag("Game2MultiplierText_FS");
  _mpfObjects.treespinCounter = GetObjectWithTag("TreespinCounter");
  _mpfObjects.devinObject = GetObjectWithTag("Devin_BG");
  _mpfObjects.dellObject = GetObjectWithTag("Dell_BG");
  _mpfObjects.introDialog = GetObjectWithTag("IntroDialog");
  _mpfObjects.introDialogClose = GetObjectWithTag("IntroDialogClose");
  _mpfObjects.introDialogClose.RegisterButtonPressedCallback(CloseGameIntro);
  _mpfObjects.game1MultiplierGroupFS = GetObjectWithTag("Game1MultiplierGroup_FS");
  _mpfObjects.game2MultiplierGroupFS = GetObjectWithTag("Game2MultiplierGroup_FS");
  _mpfObjects.paylines_G1 = GetObjectWithTag("Paylines_G1");
  _mpfObjects.paylines_G2 = GetObjectWithTag("Paylines_G2");
  
  for multiplierIndex = 2, 5 do
    _mpfObjects.game1Multipliers[multiplierIndex] = GetObjectWithTag("Game1Multiplier_" .. multiplierIndex .. "x");
    _mpfObjects.game2Multipliers[multiplierIndex] = GetObjectWithTag("Game2Multiplier_" .. multiplierIndex .. "x");   
  end

  local spinButton = SpinButton.SpinButtonObject;
  if (spinButton ~= nil) then
    Actions.AttachObject("_myvegasx/_games/devinanddell", "Slots/Prefabs/SpinButton/Meowtiplier", "Meowtiplier", spinButton, Vector3.__new(0, 0, 0), true, MeowtiplierLoadedCallback)
  end
end

function MeowtiplierLoadedCallback()
  _mpfObjects.meowtiplier = GetObjectWithTag("Meowtiplier");
end

function InitState()
  local spinMetaDataModel = GetGE2Model("SpinMetaDataModelStrategy");
  if (spinMetaDataModel ~= nil) then
    _symbolsAtIndexPosition = spinMetaDataModel.SymbolsAtIndexPosition;
  end
  _ge2GameManager = MainViewAdapter._ge2GameManager;

  -- Temporarily set the ReelSet to only have 5 reels, so quests only populate game 1. 
  local savedSlotReelStrategies = ReelSet.SlotReelStrategies;
  local game1SlotReelStrategies = {};
  for reelIndex = 1, 5 do
    game1SlotReelStrategies[reelIndex] = ReelSet.SlotReelStrategies[reelIndex];
  end
  ReelSet.SlotReelStrategies = game1SlotReelStrategies;
  Actions.RunJsonSequence("MetaCore", "Init");
  ReelSet.SlotReelStrategies = savedSlotReelStrategies;

  ForceBetSelectionDialog();

  InitMPFObjects();
  HideMultipliers();  
  _mpfObjects.mpf_ReelSet.SetActive(true);
  
  InitOverlays();

  Handle_CHANGE_WAGER_COMPLETE();
  MergeWildOverlaysToReels("Initialization");
  RegisterForEvent("CHANGE_WAGER_COMPLETE", Handle_CHANGE_WAGER_COMPLETE);

    NetworkAdapter.AddNetworkStrategies({"GenericNetworkStrategy"});
  Yield(ReelSet, "Init");
  ReelSet.PositionForIntro();

  MainViewAdapter.UpdateMainViewHUDItems();
  CheatAdapter.Init();

  RegisterForSoundEvents();

    --Set up Bet Selection Dialog exit events.
    RegisterForEvent("BetSelectionDialogOnOkPressed", PlayBetSelectedExitAnimation);
  RegisterForEvent("BetSelectionDialogOnClosePressed", PlaySkipSelectedExitAnimation);
  RegisterForEvent("OnBetSelectionDone", GameIntro);

  PlayIntroSFXAndStartMusic();

  -- Only dispatch BETBOOSTER_ONTIERSCHANGED when not recovering to picker or free spins, as this displays the bet selection.
  if (not IsRecovery()) then
    DontYield(MainViewAdapter, "InitBetSelection");
    DispatchEvent("BETBOOSTER_ONTIERSCHANGED");
  end

  Actions.RunJsonSequence("MetaCore", "SecondaryInit");
  SpinButton.Disable();
  InitPaylines();
  InitSlotSymbolBoxes();
  DontYield(BaseGameArt, "SetLocalScale", {"1.0"});
  
  DispatchEvent("BaseGameInitialized");
    DispatchEvent("CHANGE_STATE", "InitBaseGameState");
end

function RegisterForSoundEvents()
    RegisterForEvent("DND_SFX_WildMultPanel_Highlight", PlayBetSelectionPickMultiplierSFX);
    RegisterForEvent("DND_SFX_Instructions_Open", PlayInstructionsOpenSFX);
    RegisterForEvent("DND_SFX_Instructions_Close", PlayInstructionsCloseSFX);
    RegisterForEvent("DND_SFX_Devin_Wild_Multiplier_CatSequence2", PlayDevinMultiplierSFX);
    RegisterForEvent("DND_SFX_Devin_Wild_Multiplier_Doober", PlayDevinMultiplierDooberSFX);
    RegisterForEvent("DND_SFX_Dell_Wild_Multiplier_Number", PlayDellMultiplierNumberSFX);
    RegisterForEvent("DND_SFX_Dell_Wild_Multiplier_Number_Doober", PlayDellMultiplierNumberDooberSFX);
    RegisterForEvent("DND_SFX_Picker_InstructAppear", PlayPickerInstructionsSFX);
    RegisterForEvent("DND_SFX_Picker_InstructShake", PlayPickerInstructionsShakeSFX);
    RegisterForEvent("DND_SFX_Picker_Question_Setup", PlayPickerQuestionSetupSFX);
    RegisterForEvent("DND_SFX_Picker_Wheel_Ratchet", PlayPickerWheelStartSFX);
    RegisterForEvent("DND_SFX_Picker_Wheel_Stop", PlayPickerWheelStopSFX);
    RegisterForEvent("DND_SFX_Picker_Wheel_Devin_Doober", PlayPickerDooberDevinSFX);
    RegisterForEvent("DND_SFX_Picker_Wheel_Dell_Doober", PlayPickerDooberDellSFX);
    RegisterForEvent("DND_SFX_FS_DND_Multipliers_Appear", PlayFreeSpinMultipliersAppearSFX);
  RegisterForEvent("DND_SFX_FS_Multiplier_Doober", PlayFreeSpinMultipliersDooberSFX);
  RegisterForEvent("DND_SFX_FS_Bird_Flying", PlayFreeSpinBirdFlyingSFX);
  RegisterForEvent("DND_SFX_FS_DellLands_Branch", PlayFreeSpinDellLandsSFX);
  RegisterForEvent("DND_SFX_FS_Dell_SwipesBird", PlayFreeSpinDellSwipesSFX);
  RegisterForEvent("DND_SFX_FS_DevinLands_Branch", PlayFreeSpinDevinLandsSFX);
  RegisterForEvent("DND_SFX_FS_DevinAndDell_Lands_Branch", PlayFreeSpinDevinAndDellLandSFX);
    RegisterForEvent("DND_SFX_FS_to_MPF_Trans_SFX", PlayTransitionToMPFSFX);
  RegisterForEvent("DND_SFX_FS_to_MPF_Trans_SFX_Bird", PlayTransitionToMPFBirdSFX);
    RegisterForEvent("DND_SFX_Devin_TouchTap", PlayDevinTouchTapSFX); 
    RegisterForEvent("DND_SFX_Devin_TouchClean", PlayDevinTouchCleanSFX); 
    RegisterForEvent("DND_SFX_Dell_TouchTap", PlayDellTouchTapSFX); 
    RegisterForEvent("DND_SFX_Dell_Screech", PlayDellTouchScreechSFX);  
end

function PlayBetSelectionPickMultiplierSFX()
  SoundManagerAdapter.PlaySoundEffect({"BetSelectionPickMultiplier"});
end

function PlayInstructionsOpenSFX()
  SoundManagerAdapter.PlaySoundEffect({"InstructionsOpen"});
end

function PlayInstructionsCloseSFX()
  SoundManagerAdapter.StopSoundEffect({"InstructionsOpen"});
  SoundManagerAdapter.PlaySoundEffect({"InstructionsClose"});
end

function PlayDevinMultiplierSFX()
  SoundManagerAdapter.PlaySoundEffect({"DevinMultiplier"});
end

function PlayDevinMultiplierDooberSFX()
  SoundManagerAdapter.PlaySoundEffect({"DevinMultiplierDoober"});
end

function PlayDellMultiplierNumberSFX()
  SoundManagerAdapter.PlaySoundEffect({"DellMultiplierNumber"});
end

function PlayDellMultiplierNumberDooberSFX()
  SoundManagerAdapter.PlaySoundEffect({"DellMultiplierNumberDoober"});
end

function PlayPickerInstructionsSFX()
  SoundManagerAdapter.PlaySoundEffect({"PickerInstructions"});
end

function PlayPickerInstructionsShakeSFX()
  SoundManagerAdapter.PlaySoundEffect({"PickerInstructionsShake"});
end

function PlayPickerQuestionSetupSFX()
  SoundManagerAdapter.PlaySoundEffect({"PickerQuestionSetup"});
end

function PlayPickerWheelStartSFX()
  SoundManagerAdapter.PlaySoundEffect({"PickerWheelStart"});
  SoundManagerAdapter.LoopSoundEffect({"PickerWheelSpinLoop"});
end

function PlayPickerWheelStopSFX()
  SoundManagerAdapter.StopLoopingSoundEffect({"PickerWheelSpinLoop"});
  SoundManagerAdapter.PlaySoundEffect({"PickerWheelStop"});
end

function PlayPickerDooberDevinSFX()
  SoundManagerAdapter.PlaySoundEffect({"PickerDooberDevin"});
end

function PlayPickerDooberDellSFX()
  SoundManagerAdapter.PlaySoundEffect({"PickerDooberDell"});
end

function PlayFreeSpinMultipliersAppearSFX()
  SoundManagerAdapter.PlaySoundEffect({"FreeSpinMultipliersAppear"});
end

function PlayFreeSpinMultipliersDooberSFX()
  SoundManagerAdapter.PlaySoundEffect({"FreeSpinMultipliersDoober"});
end

function PlayFreeSpinBirdFlyingSFX()
  SoundManagerAdapter.PlaySoundEffect({"FreeSpinBirdFlying"});
end

function PlayFreeSpinDellLandsSFX()
  SoundManagerAdapter.PlaySoundEffect({"FreeSpinDellLands"});
end

function PlayFreeSpinDellSwipesSFX()
  SoundManagerAdapter.PlaySoundEffect({"FreeSpinDellSwipes"});
end

function PlayFreeSpinDevinLandsSFX()
  SoundManagerAdapter.PlaySoundEffect({"FreeSpinDevinLands"});
end

function PlayFreeSpinDevinAndDellLandSFX()
  SoundManagerAdapter.PlaySoundEffect({"FreeSpinDevinAndDellLand"});
end

function PlayTransitionToMPFSFX()
  SoundManagerAdapter.PlaySoundEffect({"TransitionToMPF"});
  SoundManagerAdapter.PlaySoundEffect({"TransitionToMPFSFX"});
  SoundManagerAdapter.StopMusic();
end

function PlayTransitionToMPFBirdSFX()
  SoundManagerAdapter.PlaySoundEffect({"TransitionToMPFBird"});
end

function PlayDevinTouchTapSFX()
  local index = math.random(3);
  local soundName = "DevinTouchTap" .. index;
  SoundManagerAdapter.PlaySoundEffect({soundName});
end

function PlayDevinTouchCleanSFX()
  SoundManagerAdapter.PlaySoundEffect({"DevinTouchClean"});
end

function PlayDellTouchTapSFX()
  local index = math.random(3);
  local soundName = "DellTouchTap" .. index;
  SoundManagerAdapter.PlaySoundEffect({soundName});
end

function PlayDellTouchScreechSFX()
  SoundManagerAdapter.PlaySoundEffect({"DellTouchScreech"});
end

function PlayIntroSFXAndStartMusic()
  SoundManagerAdapter.PlaySoundEffect({"Intro"});

  if (EvaluateTrigger("PickBonusInProgress")) then
    PickBonus_StartMusic();
  elseif (EvaluateTrigger("FreeSpinState")) then
    SoundManagerAdapter.SwitchMusicLoop({"FreeSpinMusicLoop", "0.5", "6.5"});
  else
    SoundManagerAdapter.SwitchMusicLoop({"MPFMusicLoop", "0.5", "6.5"});
  end
end

function InitPaylines()
  -- Load the two textures for the top and bottom games, 
  -- and set the paylines for those games to the appropriate colors. 
  Yield(Paylines, "LoadPaylineTextures");
  Paylines.SwapColors({"MVM_DND_PaylineTop_DC", "0", "40", "0"});
  Paylines.SwapColors({"MVM_DND_PaylineBottom_DC", "0", "40", "1"});
  -- Adjust transforms for paylines to counter arbitrary misallignment
  _mpfObjects.paylines_G1.GetComponent("Transform").LocalPosition = Vector3.__new(6154,-643,0);
  _mpfObjects.paylines_G2.GetComponent("Transform").LocalPosition = Vector3.__new(6154,-1108,0);
end

function InitSlotSymbolBoxes()
  -- Assign the top and bottom games to different symbol boxes. 
  for reelIndex = 1, 10 do
    local slotReel = ReelSet.SlotReelStrategies[reelIndex];
    numSlotSymbol = #slotReel.SlotSymbolStrategies;
    for rowIndex = 1, numSlotSymbol do
      local slotSymbol = slotReel.SlotSymbolStrategies[rowIndex];
      local subStrategies = slotSymbol.SubStrategies;
      if (reelIndex <= 5) then
        table.insert(subStrategies, SymbolBoxTop);
      else
        table.insert(subStrategies, SymbolBoxBottom);
      end
      slotSymbol.SubStrategies = subStrategies;
    end
  end
end

function Handle_CHANGE_WAGER_COMPLETE()
  local playerPrefsManager = GetPlayerPrefsManager();
  playerPrefsManager.SetInt("HasSetLastBet", 1);
  if (_introPlayed) then
    SetOverlays(true);
    SetMeowtiplier();
  end
end

function SetMeowtiplier()
    local betIndex = _ge2GameManager.getGameController().getWagerController().static_getCurrentWagerPerLineIndex() + 1;
    local model = GetModel();
    local baseModel = model.BaseModel;
    if (baseModel ~= nil) then
    local wagerTierMaximumMultipliers = baseModel.WagerTierMaximumMultipliers;
    if ((wagerTierMaximumMultipliers ~= nil) and (#wagerTierMaximumMultipliers >= betIndex) and (_mpfObjects.meowtiplier ~= nil)) then
      local multiplier = wagerTierMaximumMultipliers[betIndex];
      _mpfObjects.meowtiplier.AnimationSetInteger("MultValue", multiplier);
    end
  end
end

function InitBaseGameState()
  DontYield(Base, "InitializationComplete");
  Actions.RunJsonSequence("MetaCore", "InitComplete");
    DispatchEvent("CHANGE_STATE", "EvaluateRecoveryState");
end

function EvaluateRecoveryState()
  --Recover into Pick Bonus.
  if (EvaluateTrigger("PickBonusInProgress")) then
    TruckIn();
    DispatchEvent("Trigger_PickBonus");
    DispatchEvent("CHANGE_STATE", "PickBonus_RecoveryInitState");
    return;
  elseif (EvaluateTrigger("FreeSpinState")) then
    TruckIn();
    DispatchEvent("Trigger_FreeSpins");
    DispatchEvent("CHANGE_STATE", "RecoverToFreeSpinState");
    return;
  end

    DispatchEvent("CHANGE_STATE", "SelectBaseGameState");
end

function SelectBaseGameState()
  if (InAutoSpin()) then
    DispatchEvent("CHANGE_STATE", "OnOutcomeReceivedComplete");
    return;   
  end
  DispatchEvent("CHANGE_STATE", "WaitForInputState");
end

function InAutoSpin()
  local autospinsRemaining = GetWritableModelElement("AutoSpinsRemaining");
  return (autospinsRemaining ~= nil and autospinsRemaining > 0);
end

local _betSelected = false;
function PlayBetSelectedExitAnimation(betIndex)
  if (_betSelected == true) then
        return;
    end

    _betSelected = true;

    if (betIndex ~= nil) then
        local betSelectionDialog = GetObjectWithTag("BetSelectionDialog");
        if (betSelectionDialog ~= nil) then
            local animator = betSelectionDialog.GetComponent("Animator");
            if (animator ~= nil) then
                if (betIndex > -1) then
                    if (betIndex < 6) then
                        animator.SetTrigger("tier1");
                    elseif (betIndex < 9) then
                        animator.SetTrigger("tier2");
                    elseif (betIndex < 12) then
                        animator.SetTrigger("tier3");
                    elseif (betIndex >= 12) then
                        animator.SetTrigger("tier4");
                    end
          SoundManagerAdapter.PlaySoundEffect({"BetSelectionPick"});
                    Wait(1);
        end
      end

      animator.SetTrigger("cancel");
      SoundManagerAdapter.PlaySoundEffect({"BetSelectionClose"});
            Wait(1);
        end
  end
  
  DispatchEvent("BetSelectionDialogOutroFinished");
    DispatchEvent("BetSelectionDialogChoreoFinished");
end

function PlaySkipSelectedExitAnimation()
    if(_betSelected == true) then
        return;
    end

    _betSelected = true;

    local betSelectionDialog = GetObjectWithTag("BetSelectionDialog");

    if (betSelectionDialog ~= nil) then
        local animator = betSelectionDialog.GetComponent("Animator");
    if (animator ~= nil) then
            animator.SetTrigger("cancel");
      SoundManagerAdapter.PlaySoundEffect({"BetSelectionClose"});
            Wait(1);
        end
  end
  DispatchEvent("BetSelectionDialogOutroFinished");
end

function GameIntro()
  UnregisterFromEvent("OnBetSelectionDone", GameIntro);

  TruckIn();
  Handle_CHANGE_WAGER_COMPLETE();
  Wait(0.5);

  if ((not IsRecovery()) and (not HasFreeSpinsRemaining())) then
    -- Show tutorial.
    if (_mpfObjects.introDialog ~= nil) then
      _mpfObjects.introDialog.AnimationSetTrigger("PlayIntro");
      Wait(6.5);
    end
  end
end

function TruckIn()
  -- Play Truck in
  Wait(1);
  DontYield(BaseGameArt, "TweenLocalScale", {"2.0", "1.0", "1.11", "CubicOut"});
  Wait(0.5);
  SoundManagerAdapter.PlaySoundEffect({"ReelsDrop"});
  DontYield(ReelSet, "PlayIntro");
  Wait(1.5);
  _introPlayed = true;
end

function CloseGameIntro()
    _mpfObjects.introDialogClose.UnregisterButtonPressedCallback()
    if (_mpfObjects.introDialog ~= nil) then
        _mpfObjects.introDialog.AnimationSetTrigger("CloseIntro");
  end
  _introPlayed = true;
end

function WaitForInputState()
  Actions.RunJsonSequence("MetaCore", "ReadyForInput");
  Actions.RunJsonSequence("MetaCore", "UnlockAllButBetSelection");
    SlotSymbolConfiguration_G1.ClearIgnoredSubStrategies();
    SlotSymbolConfiguration_G2.ClearIgnoredSubStrategies();
end

function RequestOutcomeState()
  CloseGameIntro();
  WinCelebration.ClearEpicWinEffects();
  ResetModel();
  DontYield(ReelSet, "StartSpin");
  Actions.RunJsonSequence("MetaCore", "StartManualSpin");
  SoundManagerAdapter.StopLoopingSoundEffect({"ReelSpinLoop"});
  SoundManagerAdapter.PlaySoundEffect({"ReelSpinStart"});
  SoundManagerAdapter.LoopSoundEffect({"ReelSpinLoop"});
  
  if (_stopGame1WildFXOnSpinStart) then
    _stopGame1WildFXOnSpinStart = false;
    StopSpinsToWildFX();
  end

  DispatchEvent("CHANGE_STATE", "OutcomeReceivedState");
end

function HideMultipliers()
  _mpfObjects.game1FreeSpinMultiplierText.SetText("1x");
  _mpfObjects.game2FreeSpinMultiplierText.SetText("1x");
  if (_showingGame1Multiplier) then
    if (_mpfObjects.devinObject ~= nil) then
      _mpfObjects.devinObject.AnimationSetTrigger("Exit_Mult");
      -- Only play 1 instance of DevinMultiplierClose at a time.
      SoundManagerAdapter.PlaySoundEffect({"DevinMultiplierClose", "0.5", "0", "true", "false", "1"});
    end
    _showingGame1Multiplier = false;
  end
  if (_showingGame2Multiplier) then
    if (_mpfObjects.dellObject ~= nil) then
      _mpfObjects.dellObject.AnimationSetTrigger("Exit_Mult");
      -- Only play 1 instance of DevinMultiplierClose at a time.
      SoundManagerAdapter.PlaySoundEffect({"DevinMultiplierClose", "0.5", "0", "true", "false", "1"});
    end
    _showingGame2Multiplier = false;
  end
end

function OutcomeReceivedState()
  HideWildFlameOverlays();
  HideMultipliers();
  DecrementSpinsToWild();
  PlayReelsStoppingChoreography("Slots_SpinManual");

  if (EvaluateTrigger("PickBonusTriggered")) then
    DispatchEvent("Trigger_PickBonus");
    DispatchEvent("CHANGE_STATE", "TransitionToPickBonusState");
    return;
  end
  
  Actions.RunJsonSequence("MetaCore", "CycleOutcomes");
  Actions.RunJsonSequence("MetaCore", "ShowMetaFeatures");
  DispatchEvent("CHANGE_STATE", "WaitForInputState");
end

function PlayReelsStoppingChoreography(SpinSource)
    -- The choreography for the character animations and overlays is broken down into 2 parts.
  -- Before the reels stop, characters may start animating, and possibly wild reels are shown.
  -- After the reels stop, overlays are activated, and possibly extra wait time is needed
  -- if there are multiplier animations playing from before the reels stopped.  
  ShowSpinningReelsChoreography();

  -- Complete the spin
  Actions.RunJsonSequence("MetaCore", "UpdateBalances");
  Yield(ReelSet, "StopSpin");
    SoundManagerAdapter.StopLoopingSoundEffect({"ReelSpinLoop"});
  Actions.RunJsonSequence("MetaCore", "UpdateElementsAndEvents");
  Actions.RunJsonSequence("MetaCore", "CompleteSpin");
  Actions.RunJsonSequence("MetaCore", "LogSpinResult");

  ShowStoppedReelsChoreography(SpinSource);
end

function ShowSpinningReelsChoreography(isFreeSpin)
  isFreeSpin = isFreeSpin or false;
    local totalWager = _ge2GameManager.getGameController().getWagerController().getTotalWager();
    local model = GetModel();
  local baseModel = model.BaseModel;
    local game1Multiplier = 1;
  local game2Multiplier = 1;
  local wildReelIndices = {};
  local showingDevinAnimation = false;
  local showingDellAnimation = false;

  -- Determine if top or bottom game features are triggering.
    if (baseModel ~= nil) then
    game1Multiplier = baseModel.Game1Multiplier;
    game2Multiplier = baseModel.Game2Multiplier;
    local wagerTierEntries = baseModel.WagerTierEntries;
    if (wagerTierEntries ~= nil) then
            local wagerTierEntry = wagerTierEntries[totalWager];
      if (wagerTierEntry ~= nil) then
        local spinsToWild = wagerTierEntry.SpinsToWild;
        if (spinsToWild == 10) then
          -- Only show a Devin animation if there is a multiplier to show.
          if (game1Multiplier > 1) then
            showingDevinAnimation = true;
          end
          _stopGame1WildFXOnSpinStart = true;
        end
        wildReelIndices = wagerTierEntry.WildReelIndices;
            end

      if ((wildReelIndices ~= nil) and (#wildReelIndices > 0)) then
        for reelIndex = 1,#wildReelIndices do
          local symbolIndex = wildReelIndices[reelIndex];
          local symbolName = _symbolsAtIndexPosition[symbolIndex];
          if (symbolName == "WILDFLAMES") then
            showingDellAnimation = true;
          end
        end 
      end
    end
    end

  if (not isFreeSpin) then
    if (showingDevinAnimation and game1Multiplier ~= nil) then
      ShowDevinAnimation(game1Multiplier);
    end

    if (showingDellAnimation and game2Multiplier ~= nil) then
      ShowDellAnimation(game2Multiplier)
    end

    -- Wait for character animations.
    if (showingDevinAnimation) then
      Wait(2.5);
    elseif (showingDellAnimation) then
      Wait(1.5);
    end
  end

  ShowWildFlames(wildReelIndices);
end

function ShowWildFlames(wildReelIndices)
  local showingWildFlames = false;
  if ((wildReelIndices ~= nil) and (#wildReelIndices > 0)) then
    for reelIndex = 1,#wildReelIndices do
      local symbolIndex = wildReelIndices[reelIndex];
      local symbolName = _symbolsAtIndexPosition[symbolIndex];
      if (symbolName == "WILDFLAMES") then
        SetWildFlamesReelOverlay(reelIndex);
        showingWildFlames = true;
      end
    end 
  end
  if (showingWildFlames) then
    Wait(2.0);
  end
end

function ShowDevinAnimation(game1Multiplier)
  _showingGame1Multiplier = false;
  if (game1Multiplier > 1) then
    SetMultiplierTextAssets(1, game1Multiplier);
    if (_mpfObjects.devinObject ~= nil) then
      _mpfObjects.devinObject.AnimationSetTrigger("BG_Mult");
    end
    _showingGame1Multiplier = true;
  end
end

function ShowDellAnimation(game2Multiplier)
  _showingGame2Multiplier = false;
  if (game2Multiplier > 1) then
    SetMultiplierTextAssets(2, game2Multiplier);
    if (_mpfObjects.dellObject ~= nil) then
      _mpfObjects.dellObject.AnimationSetTrigger("BG_Mult");
      SoundManagerAdapter.PlaySoundEffect({"DellMultiplier"});
    end
    _showingGame2Multiplier = true;
  else
    if (_mpfObjects.dellObject ~= nil) then
      _mpfObjects.dellObject.AnimationSetTrigger("BG_Wild");
      SoundManagerAdapter.PlaySoundEffect({"DellNoMultiplier"});
    end
  end
end

function SetMultiplierTextAssets(gameIndex, multiplierIndex)
  if (gameIndex == 1) then
    for index = 2, 5 do
      _mpfObjects.game1Multipliers[index].SetActive(false);
    end
    _mpfObjects.game1Multipliers[multiplierIndex].SetActive(true);
  else
    for index = 2, 5 do
      _mpfObjects.game2Multipliers[index].SetActive(false);
    end
    _mpfObjects.game2Multipliers[multiplierIndex].SetActive(true);
  end
end

function ShowStoppedReelsChoreography(SpinSource)
  -- Show overlays and merge to reels
  local waitTime = 0.5;
  if (_showingGame1Multiplier) then
    waitTime = 3.0;
  elseif (_showingGame2Multiplier) then
    waitTime = 1.0;
  end
  local animationsTriggered = SetOverlays();
  if (animationsTriggered) then
    Wait(waitTime);
  end
  MergeWildOverlaysToReels(SpinSource);
end

function AutoSpinRequestOutcomeState()
  WinCelebration.ClearEpicWinEffects();
  DontYield(WinCycler, "EndCycleOutcomes");
  HideWildFlameOverlays();
  HideMultipliers();
  DecrementSpinsToWild();
  ResetModel();
  DontYield(ReelSet, "StartSpin");
  Actions.RunJsonSequence("MetaCore", "StartAutoSpin");
  SoundManagerAdapter.StopLoopingSoundEffect({"ReelSpinLoop"});
  SoundManagerAdapter.PlaySoundEffect({"ReelSpinStart"});
  SoundManagerAdapter.LoopSoundEffect({"ReelSpinLoop"});

  if (_stopGame1WildFXOnSpinStart) then
    _stopGame1WildFXOnSpinStart = false;
    StopSpinsToWildFX();
  end

  DispatchEvent("CHANGE_STATE", "AutoSpinOutcomeReceivedState");
end

function AutoSpinOutcomeReceivedState()
  PlayReelsStoppingChoreography("Slots_SpinAuto");

  if (EvaluateTrigger("PickBonusTriggered")) then
    DispatchEvent("Trigger_PickBonus");
    DispatchEvent("CHANGE_STATE", "TransitionToPickBonusState");
    return;
  end
  
  DispatchEvent("CHANGE_STATE", "AutoSpinOutcomeReceivedNormalState");
end

function AutoSpinOutcomeReceivedNormalState()
  DontYield(WinCelebration, "Play");
  Actions.RunJsonSequence("MetaCore", "ShowOutcomes");
  Actions.RunJsonSequence("MetaCore", "ShowMetaFeatures");
  SpinButton.SetSpinButtonState({"AutoSpin"});
  SpinButton.Spin();
end

function TransitionToPickBonusState()
  DontYield(WinCycler, "ShowOutcomes");
  Yield(WinCelebration, "Play");
  DontYield(WinCycler, "HideOutcomes");
    WinCelebration.ClearEpicWinEffects();
  SoundManagerAdapter.FadeMusic({"0.0", "0.15"});
  SoundManagerAdapter.PlaySoundEffect({"AllBonusHighlight"});
    SlotSymbolHighlight.SetBonusSymbolName({"BONUS"});
    AnimateBonusSymbols();
    Yield(WinCycler, "ShowBonusHighlight");
    Wait(1.0);
  SoundManagerAdapter.StopMusic();
    DontYield(WinCycler, "HideBonusHighlight");
    UIControls.Hide();
  SidebarCollection.UnlockAllItems();
  Yield(SidebarCollection, "Hide");
  Actions.RunJsonSequence("MetaCore", "LockAll");
    SoundManagerAdapter.StopLoopingSoundEffect({"DellWildFlamesLoop"});
    DispatchEvent("CHANGE_STATE", "PickBonus_InitState");
end

function AnimateBonusSymbols()
  for i = 1, 5 do
    local slotReel = ReelSet.SlotReelStrategies[i];
    for j = 0, 2 do
      local slotSymbol = slotReel.GetSlotSymbol(j);
      local symbolName = slotSymbol.CurrentSymbolName;
      if (symbolName == "BONUS") then
        local reelIndex = slotSymbol.ReelIndex;
        local rowIndex = slotSymbol.RowIndex;
        DispatchEvent("BonusTriggered", { reelIndex, rowIndex }, "System.Collections.Generic.List`1[System.Int32]");
      end
    end
  end
end

function RecoverToFreeSpinState()
  FreeSpinShowMultipliers();
  Yield(ReelSet, "DisplayOutcome");
  ReelSet.ChangeActiveReelStrip({"FreeSpinReels"});
  SpinButton.SetSpinButtonState({"FreeSpin"});
  SpinButton.Disable();
  Actions.RunJsonSequence("MetaCore", "LeaveWaitForInput");
  UIControls.Hide();
  SidebarCollection.UnlockAllItems();
  Yield(SidebarCollection, "Hide");
  Actions.RunJsonSequence("MetaCore", "LockAll");
  SlotSymbolConfiguration_G1.SetIgnoredSubStrategies({"QuestOverlay", "ProgressiveOverlay", "HighRollerProgressiveOverlay"});
  SlotSymbolConfiguration_G2.SetIgnoredSubStrategies({"QuestOverlay", "ProgressiveOverlay", "HighRollerProgressiveOverlay"});
  WinCycler.ClearIgnoredSubStrategies();
  FreeSpinUpdateCounter();
  DontYield(Base, "InitializationComplete");
    GetMPFObjects().mpf_ReelSet.SetActive(true);
  DispatchEvent("RecoveryToFS");
    Wait(1.0)
  DispatchEvent("Trigger_FreeSpins");
    DispatchEvent("CHANGE_STATE", "FreeSpinRequestOutcomeState")
end

function FreeSpinShowMultipliers()
    local model = GetModel();
  local baseModel = model.BaseModel;
  if (baseModel ~= nil) then
    local game1Multiplier = baseModel.Game1Multiplier;
    local game2Multiplier = baseModel.Game2Multiplier;

    if (game1Multiplier > 1) then
      _mpfObjects.game1FreeSpinMultiplierText.SetText(game1Multiplier .. "X");
    else
      _mpfObjects.game1FreeSpinMultiplierText.SetText("1x");
    end

    if (game2Multiplier > 1) then
      _mpfObjects.game2FreeSpinMultiplierText.SetText(game2Multiplier .. "X");
    else
      _mpfObjects.game2FreeSpinMultiplierText.SetText("1x");
    end
  end
end

function FreeSpinInit()
  Actions.RunJsonSequence("MetaCore", "ShowMetaFeatures");
  ResetModel();
  WritableModelUtility.ClearValue({"FreeSpinsTotal"});
  Yield(NetworkAdapter, "GetMetaData");
  FreeSpinShowMultipliers();
  SetOverlays();
  Yield(ReelSet, "DisplayOutcome");
  ReelSet.ChangeActiveReelStrip({"FreeSpinReels"});
  SpinButton.SetSpinButtonState({"FreeSpin"});
  SpinButton.Disable();
  WritableModelUtility.ClearValue({"FreeSpinTotalWinAmount"});
  Actions.RunJsonSequence("MetaCore", "LeaveWaitForInput");
  Actions.RunJsonSequence("MetaCore", "LockAll");
  SlotSymbolConfiguration_G1.SetIgnoredSubStrategies({"QuestOverlay", "ProgressiveOverlay", "HighRollerProgressiveOverlay"});
  SlotSymbolConfiguration_G2.SetIgnoredSubStrategies({"QuestOverlay", "ProgressiveOverlay", "HighRollerProgressiveOverlay"});
  WinCycler.ClearIgnoredSubStrategies();
  FreeSpinUpdateCounter();
  DontYield(Base, "InitializationComplete");
end

function FreeSpinUpdateCounter()
  local freeSpinsRemaining = GetWritableModelElement("FreeSpinsRemaining");
  if ((_mpfObjects.treespinCounter ~= nil) and (freeSpinsRemaining ~= nil)) then
    local message = "";
    if (freeSpinsRemaining > 1) then
      message = freeSpinsRemaining .. " Spins Remaining!";
    elseif (freeSpinsRemaining == 1) then
      message = "1 Spin Remaining!";
    else
      message = "Last Spin";
    end
    _mpfObjects.treespinCounter.SetText(message);
  end
end

function FreeSpinRequestOutcomeState()
  MainViewAdapter.UpdateMainViewHUDItems();
  Actions.RunJsonSequence("MetaCore", "LockAll");
  Actions.RunJsonSequence("MetaCore", "LeaveWaitForInput");
  Actions.RunJsonSequence("ReelSet33333x2", "StartSpin");
  Actions.RunJsonSequence("MetaCore", "StartFreeSpin");
  HideWildFlameOverlays();
  FreeSpinUpdateCounter();
  DecrementSpinsToWild();
  Yield(NetworkAdapter, "FreeSpin");

  if (_stopGame1WildFXOnSpinStart) then
    _stopGame1WildFXOnSpinStart = false;
    StopSpinsToWildFX();
  end

  DispatchEvent("CHANGE_STATE", "FreeSpinOutcomeReceivedState");
end

function FreeSpinOutcomeReceivedState()
  -- This shows the wild flames on reels but does not animate characters. 
  ShowSpinningReelsChoreography(true);

  DontYield(MainViewAdapter, "TriggerInformOfBalancesEvent");
  Actions.RunJsonSequence("ReelSet33333x2", "StopSpin");

  local animationsTriggered = SetOverlays();
  FreeSpinShowMultipliers();
  if (animationsTriggered) then
    Wait(0.5);
  end
  MergeWildOverlaysToReels("Slots_FreeSpin");

  HighlightFreeSpinMultipliers();

  Actions.RunJsonSequence("MetaCore", "UpdateElementsAndEvents");
  Yield(WinCelebration, "Play");
  Actions.RunJsonSequence("MetaCore", "LogSpinResult");

  Yield(WinCycler, "ShowOutcomes");
  Actions.RunJsonSequence("MetaCore", "ShowMetaFeatures");
  DontYield(WinCycler, "HideOutcomes");
  DontYield(MainViewAdapter, "TriggerInformOfBalancesEvent");
  if (EvaluateTrigger("FreeSpinState")) then
    DispatchEvent("CHANGE_STATE", "FreeSpinRetriggerFreeSpinState");
  else
    DispatchEvent("CHANGE_STATE", "FreeSpinSpinOrCompleteState");
  end
end

function HighlightFreeSpinMultipliers()
  -- determine of there are payline wins in the top or bottom games or both, and highlight the appropriate multipliers.
  local game1Win = false;
  local game2Win = false;
  local paylineModel = GetGE2Model("PaylineModelStrategy");
  if (paylineModel ~= nil) then
    local payLineWins = paylineModel.PLW;
    if ((payLineWins ~= nil) and (#payLineWins >= 3)) then
      for index = 1, #payLineWins, 3 do
        local paylineIndex = payLineWins[index];
        if (paylineIndex >= 40) then
          game2Win = true;
        else
          game1Win = true;
        end
      end
    end
  end
  if (game1Win) then
    _mpfObjects.game1MultiplierGroupFS.AnimationSetTrigger("triggerMult");
    SoundManagerAdapter.PlaySoundEffect({"FreeSpinBlueMultiplier"});    
  end
  if (game2Win) then
    _mpfObjects.game2MultiplierGroupFS.AnimationSetTrigger("triggerMult");
    SoundManagerAdapter.PlaySoundEffect({"FreeSpinRedMultiplier"});   
  end
  if (game1Win or game2Win) then
    Wait(1);
  end
end

function FreeSpinRetriggerFreeSpinState()
  SlotSymbolConfiguration_G1.ClearIgnoredSubStrategies();
  SlotSymbolConfiguration_G2.ClearIgnoredSubStrategies();
  WinCelebration.ClearEpicWinEffects();
  Yield(WinCycler, "ShowBonusHighlight");
  DontYield(WinCycler, "HideBonusHighlight");
  DispatchEvent("TreespinIncrementCount");
  PlayDellMultiplierNumberSFX();
  Wait(1.0);
  FreeSpinUpdateCounter();
  Actions.RunJsonSequence("MetaCore", "CycleOutcomes");
  DispatchEvent("CHANGE_STATE", "FreeSpinCompleteRetrigger");
end

function FreeSpinCompleteRetrigger()
  Actions.RunJsonSequence("MetaCore", "LeaveWaitForInput");
  SpinButton.SetAmount();
  SlotSymbolConfiguration_G1.SetIgnoredSubStrategies({"QuestOverlay", "ProgressiveOverlay", "HighRollerProgressiveOverlay"});
  SlotSymbolConfiguration_G2.SetIgnoredSubStrategies({"QuestOverlay", "ProgressiveOverlay", "HighRollerProgressiveOverlay"});
  DispatchEvent("CHANGE_STATE", "FreeSpinSpinOrCompleteState");
end

function FreeSpinSpinOrCompleteState()
  DontYield(WinCycler, "HideOutcomes");
  SpinButton.SetSpinButtonState({"FreeSpin"});
  SpinButton.Spin();
end

-- HARDCODED FUNCTIONS IN STRATEGIES START
--The functions below are hardcoded state names into the SpinButtonState, AutoSpinButtonStrategy, and SpinButtonAutoSpinState
function OnSpin()
  Actions.RunJsonSequence("MetaCore", "LeaveWaitForInput");
  Actions.RunJsonSequence("MetaCore", "LockAll");
  Yield(MainViewAdapter, "SpendCredits", {"RequestOutcomeState", "WaitForInputState"});
end

function OnAutoSpin()
  Actions.RunJsonSequence("MetaCore", "LeaveWaitForInput");
  Actions.RunJsonSequence("MetaCore", "LockAll");
  DontYield(MainViewAdapter, "SpendCredits", {"AutoSpinRequestOutcomeState", "WaitForInputState"});
end

function OnOutcomeReceivedComplete()
  if (HasFreeSpinsRemaining()) then
    DispatchEvent("CHANGE_STATE", "FreeSpinRequestOutcomeState");
  else
    WinCelebration.ClearEpicWinEffects();
    --Validate auto spin
    Actions.RunJsonSequence("MetaCore", "LockAll");
    DontYield(MainViewAdapter, "SpendCredits", {"AutoSpinRequestOutcomeState", "WaitForInputState"});
  end
end

function OnAutoSpinComplete()
  WinCycler.CycleOutcomes();
  Actions.RunJsonSequence("MetaCore", "ShowMetaFeatures");
  DispatchEvent("CHANGE_STATE", "WaitForInputState");
end

--Dispatched from SpinButtonFreeSpinState
function OnFreeSpinComplete()
  Actions.RunJsonSequence("MetaCore", "BonusGameComplete");
  local winTotalText = GetObjectWithTag("WinTotalText");
  local freeSpinTotalWinAmount = GetWritableModelElement("FreeSpinTotalWinAmount");
  local formattedFreeSpinTotalWinAmount = NumberFormatter.FormatNumber(freeSpinTotalWinAmount, NumberFormatter.FORMATTING.COMMAS_ONLY);
  winTotalText.SetText(formattedFreeSpinTotalWinAmount);
  GetMPFObjects().freespinsContainer.AnimationSetTrigger("PlayCelebration");
    SoundManagerAdapter.StopLoopingSoundEffect({"DellWildFlamesLoop"});
    Wait(16.0);
  Yield(SidebarCollection, "Hide");

  Actions.RunJsonSequence("MetaCore", "UpdateBalances");
  DontYield(MainViewAdapter, "ForceChipsToRemoteBalace");
  WinCelebration.ClearEpicWinEffects();
  DontYield(WinCycler, "HideOutcomes");
  ReelSet.ChangeActiveReelStrip({"Reels"});
  SpinButton.SetSpinButtonState({"Spin"});
  SpinButton.SaveSpinButtonState();
  WritableModelUtility.ClearValue({"FreeSpinTotalWinAmount"});
  SidebarCollection.UnlockAllItems();
  Yield(SidebarCollection, "Show");
  WinCycler.ClearIgnoredSubStrategies();

  HideMultipliers();

  ResetModel();
  Yield(NetworkAdapter, "GetMetaData");
  DontYield(ReelSet, "DisplayOutcome");
  Handle_CHANGE_WAGER_COMPLETE();
  Wait(2.0);
  SoundManagerAdapter.SwitchMusicLoop({"MPFMusicLoop"});
  DispatchEvent("CHANGE_STATE", "SelectBaseGameState");
end
-- HARDCODED FUNCTIONS IN STRATEGIES END