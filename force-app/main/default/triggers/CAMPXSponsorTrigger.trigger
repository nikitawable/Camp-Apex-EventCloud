/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger CAMPXSponsorTrigger on CAMPX__Sponsor__c (before insert,before update,after insert,after update) {
    if(Trigger.isInsert && trigger.isBefore)
    {
        CAMPXSponsorTriggerHandler.setSponsorStatus(Trigger.New);
        CAMPXSponsorTriggerHandler.setSponsorTier(Trigger.New);
        CAMPXSponsorTriggerHandler.haveEventForAcceptedSponser(Trigger.New);
    }
    if(Trigger.isUpdate && trigger.isBefore)
    {
        CAMPXSponsorTriggerHandler.setSponsorTier(Trigger.newMap, Trigger.oldMap);
    }
    if(Trigger.isInsert && Trigger.isAfter)
    {
        CAMPXSponsorTriggerHandler.calculateEventRevenue(Trigger.newMap,null);
    }
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        CAMPXSponsorTriggerHandler.calculateEventRevenue(Trigger.newMap,Trigger.oldMap);
        CAMPXSponsorTriggerHandler.updategrossRevenueForCancelled(Trigger.newMap,Trigger.oldMap);
    }
}