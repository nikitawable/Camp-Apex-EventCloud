public class CAMPXSponsorTriggerHandler {
    public static void setSponsorStatus(List<CAMPX__Sponsor__c> sponsorList)
    {
     	for(CAMPX__Sponsor__c sponsor: sponsorList)
        {
            if(sponsor.CAMPX__Status__c == null)
            {
                sponsor.CAMPX__Status__c = 'Pending';
            }
            if(sponsor.CAMPX__Email__c == null)
            {
                sponsor.CAMPX__Email__c.addError('A sponsor can not be created without an email address');
            }
        }
    }
    
    public static void setSponsorTier(List<CAMPX__Sponsor__c> sponsorList)
    {
        for(CAMPX__Sponsor__c sponsor : sponsorList)
        {
            getSponsorTier(sponsor);             		  
        }
    }
	public static void setSponsorTier(Map<Id,CAMPX__Sponsor__c> newsponsormap,Map<Id,CAMPX__Sponsor__c> oldsponsormap)
    {
     	for(CAMPX__Sponsor__c sponsor : newsponsormap.values())
        {
            if(sponsor.CAMPX__ContributionAmount__c != oldsponsormap.get(sponsor.Id).CAMPX__ContributionAmount__c)
            {
				getSponsorTier(sponsor);             		  
            }
        }
    }
    
    private static void getSponsorTier(CAMPX__Sponsor__c sponsor)
    {
             	if(sponsor.CAMPX__ContributionAmount__c == null || sponsor.CAMPX__ContributionAmount__c <= 0)
                {
                    sponsor.CAMPX__Tier__c = null;
                }
                else if(sponsor.CAMPX__ContributionAmount__c < 1000)
                {
                    sponsor.CAMPX__Tier__c = 'Bronze';
                }
                else if(sponsor.CAMPX__ContributionAmount__c <5000)
                {
                    sponsor.CAMPX__Tier__c = 'Silver';
                }   
                else if(sponsor.CAMPX__ContributionAmount__c > 5000)
                {
                    sponsor.CAMPX__Tier__c = 'Gold';
                } 
    }
    
    public static void haveEventForAcceptedSponser(List<CAMPX__Sponsor__c> sponsorList)
    {
     	for(CAMPX__Sponsor__c sponsor : sponsorList)
        {
            if(sponsor.CAMPX__Status__c == 'Accepted' && sponsor.CAMPX__Event__c == null)
            {
             	sponsor.addError('A Sponsor must be associated with an event before being Accepted.');   
            }
        }
    }
    
    public static void calculateEventRevenue(Map<Id,CAMPX__Sponsor__c> sponsorMap,Map<Id,CAMPX__Sponsor__c> oldSponsorMap)
    {
        Set<Id> eventIdSet = new Set<Id>();
        List<CAMPX__Event__c> updateEvents = new List<CAMPX__Event__c>();
        for(CAMPX__Sponsor__c sponsor: sponsorMap.values())
        {
          	if(sponsor.CAMPX__Event__c != null) eventIdSet.add(sponsor.CAMPX__Event__c);
        }
        Map<Id,CAMPX__Event__c> eventMap = new Map<Id,CAMPX__Event__c>([SELECT Id,CAMPX__GrossRevenue__c FROM CAMPX__Event__c WHERE Id In:eventIdSet]);
        
        for(CAMPX__Sponsor__c sponsor: sponsorMap.values())
        {
            if((oldSponsorMap == null && sponsor.CAMPX__Status__c == 'Accepted') || (oldSponsorMap != null && sponsor.CAMPX__Status__c == 'Accepted' && oldSponsorMap.get(sponsor.Id).CAMPX__Status__c != 'Accepted'))
            {
                if(eventMap.get(sponsor.CAMPX__Event__c).CAMPX__GrossRevenue__c != null)
                {
                	eventMap.get(sponsor.CAMPX__Event__c).CAMPX__GrossRevenue__c += sponsor.CAMPX__ContributionAmount__c;   
                    updateEvents.add(eventMap.get(sponsor.CAMPX__Event__c));

                }
                else
                {
                    eventMap.get(sponsor.CAMPX__Event__c).CAMPX__GrossRevenue__c = sponsor.CAMPX__ContributionAmount__c;
                    updateEvents.add(eventMap.get(sponsor.CAMPX__Event__c));
                }      
            }
            if(sponsor.CAMPX__Status__c == 'Accepted' && oldSponsorMap != null && oldSponsorMap.get(sponsor.Id).CAMPX__ContributionAmount__c != null)
            {
                if(oldSponsorMap.get(sponsor.Id).CAMPX__ContributionAmount__c != sponsor.CAMPX__ContributionAmount__c)
                {
                 	eventMap.get(sponsor.CAMPX__Event__c).CAMPX__GrossRevenue__c  = eventMap.get(sponsor.CAMPX__Event__c).CAMPX__GrossRevenue__c - oldSponsorMap.get(sponsor.Id).CAMPX__ContributionAmount__c + sponsor.CAMPX__ContributionAmount__c;
                    updateEvents.add(eventMap.get(sponsor.CAMPX__Event__c));   
                }
            }
        }
        update updateEvents;
    }
    
    public static void updategrossRevenueForCancelled(Map<Id,CAMPX__Sponsor__c> newMap,Map<Id,CAMPX__Sponsor__c> oldMap)
    {
        Set<Id> eventIdSet = new Set<Id>();
        List<CAMPX__Event__c> updateEvents = new List<CAMPX__Event__c>();
        for(CAMPX__Sponsor__c sponsor: newMap.values())
        {
          	if(sponsor.CAMPX__Event__c != null) eventIdSet.add(sponsor.CAMPX__Event__c);
        }
        for(CAMPX__Sponsor__c sponsor: oldMap.values())
        {
          	if(sponsor.CAMPX__Event__c != null) eventIdSet.add(sponsor.CAMPX__Event__c);
        }
        Map<Id,CAMPX__Event__c> eventMap = new Map<Id,CAMPX__Event__c>([SELECT Id,CAMPX__GrossRevenue__c FROM CAMPX__Event__c WHERE Id In:eventIdSet]);
        
        for(CAMPX__Sponsor__c sponsor: newMap.values())
        {
            if(oldMap.get(sponsor.Id).CAMPX__Status__c != null && oldMap.get(sponsor.Id).CAMPX__Status__c == 'Accepted' && sponsor.CAMPX__Status__c != 'Accepted' && oldMap.get(sponsor.Id).CAMPX__ContributionAmount__c != null)
            {
                eventMap.get(sponsor.CAMPX__Event__c).CAMPX__GrossRevenue__c -= oldMap.get(sponsor.Id).CAMPX__ContributionAmount__c; 
                updateEvents.add(eventMap.get(sponsor.CAMPX__Event__c));
            }
            else if(oldMap.get(sponsor.Id).CAMPX__Event__c != null && sponsor.CAMPX__Event__c == null && oldMap.get(sponsor.Id).CAMPX__ContributionAmount__c != null)
            {
             	eventMap.get(oldMap.get(sponsor.Id).CAMPX__Event__c).CAMPX__GrossRevenue__c -= oldMap.get(sponsor.Id).CAMPX__ContributionAmount__c;
                updateEvents.add(eventMap.get(oldMap.get(sponsor.Id).CAMPX__Event__c));
            }
        }
        if(updateEvents.size()>0) update updateEvents;
    }
}