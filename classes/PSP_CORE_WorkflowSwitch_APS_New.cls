/*Place for Documentation*/
   //Static final Boolean StopRecusion=True;
    //Public Static  Boolean UpdateCase=True;
    
/*Place for Documentation*/
public with sharing class PSP_CORE_WorkflowSwitch_APS_New {
    public PSP_Core_WorkflowSwitch_APS_New(){

    }
    public boolean tssRestartCheck=false;
/*Place for Documentation*/
       public void  ClanceWorkflow(Case objCase)
    {
      List<Task> taskToBeCancelled;
       List<Task> lstTask = new List<Task>();
      system.debug('Called WFSnew method1');
      APS_Util_Constants.cancelworkflowcheck = False;
        try{
            APS_PreventRecursion_Helper.PreventTriggerWorkflowsRecusive=false;
            //Case currentCase=[select id,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c,PSP_CORE_ReInvoke__c    from Case where id=:objCase.id LIMIT 50000];
            //currentCase.PSP_CORE_Current_Workflow__c='';
           // currentCase.PSP_CORE_Current_Workflow_ID__c='';
           // currentCase.PSP_CORE_ReInvoke__c=false;
           //update currentCase;
            
            Set<string> setStaus= new set<String>{system.label.PSP_CORE_Adverse_Event_Assigned_Status,system.label.PSP_CORE_Not_Assigned,system.label.PSP_CORE_InProgress};
           
           /*
            List<Task> lstTask =[Select id,Status from Task where WhatId=: objCase.Id and Status in : setStaus LIMIT 50000];
            for (Task ObjTask : lstTask){
                objTask.Status=system.label.PSP_CORE_Cancelled;
                objtask.APS_Skip_Validations__c = true;
                
            }
           */            
            List<APS_Case_Workflow_Step__c> lstCWFS=[select Id, APS_Related_Object_SFDC_ID__c,APS_Workflow_Step_Name__c, APS_Status__c,APS_Workflow__c from APS_Case_Workflow_Step__c where APS_Related_Case__c=: objCase.Id and APS_Status__c in : setStaus  and  APS_Workflow_Step_Name__c!='Adverse Event Follow-Up' LIMIT 50000];            
            //List<PSP_CORE_Program_Affiliation__c> prgaff = [select id,name,(select id from Cases__r where id =: objcase.id) from PSP_CORE_Program_Affiliation__c ];
            
            case cOBJ = [select id,PSP_CORE_Program_Affiliation__c,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Change__c,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Reason__c,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c  from case where id=:objcase.id];
            List<PSP_CORE_Treatment__c> treat = [select id,name,PSP_CORE_Treatment_Change__c,PSP_CORE_Treatment_Reason__c from PSP_CORE_Treatment__c where PSP_CORE_Program__c=:cOBJ.PSP_CORE_Program_Affiliation__c ];
            system.debug('lstCWFS+++'+lstCWFS);
            string programchange = cOBJ.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Change__c;
            string programreason = cOBJ.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Reason__c;
            system.debug('Program Reason'+cOBJ.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Reason__c);
            system.debug(cOBJ.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Change__c+'programchange');
            string treatmentchange;
            string treatreason;
            for(PSP_CORE_Treatment__c tre: treat){
            system.debug(tre.PSP_CORE_Treatment_Change__c+'treatmentchange');
                treatmentchange = tre.PSP_CORE_Treatment_Change__c ;
                treatreason = tre.PSP_CORE_Treatment_Reason__c;
            } 
            for (APS_Case_Workflow_Step__c objCWFS: lstCWFS){
                
                       if(
    ( (objCWFS.APS_Workflow_Step_Name__c== System.Label.PSP_CORE_r20_InfusionDateAssessmentCall)&& !(treatmentchange.contains('Stopped') || programchange.contains('Stop') || treatmentchange.contains('Interrupted Treatment') || programreason.contains('Reactive PSP Service')) && objCWFS.APS_Workflow__c.contains(System.Label.PSP_CORE_r20_Initialworkflowconsented))
        ||
        ((objCWFS.APS_Workflow_Step_Name__c==System.Label.PSP_CORE_r20_Assessment_Call) && !(treatmentchange.contains('Stopped') || programchange.contains('Stop') || treatmentchange.contains('Interrupted Treatment') || programreason.contains('Reactive PSP Service')) && objCWFS.APS_Workflow__c.contains(System.Label.PSP_CORE_r20_Initialworkflowconsented))
        ||
        ((objCWFS.APS_Workflow_Step_Name__c==System.Label.PSP_CORE_r20_WelcomePackCall) && !(treatmentchange.contains('Stopped') || programchange.contains('Stop') || treatmentchange.contains('Interrupted Treatment') || programreason.contains('Reactive PSP Service')) && objCWFS.APS_Workflow__c.contains(System.Label.PSP_CORE_r20_Initialworkflowconsented))
        ||
        ((objCWFS.APS_Workflow_Step_Name__c==System.Label.PSP_CORE_r20_WelcomeCall) && !(treatmentchange.contains('Stopped') || programchange.contains('Stop') || treatmentchange.contains('Interrupted Treatment') || programreason.contains('Reactive PSP Service')) && objCWFS.APS_Workflow__c.contains(System.Label.PSP_CORE_r20_Initialworkflowconsented))
        ){
                     System.debug('--in if---');
                     }                          
                    
                /*if(objCWFS.APS_Workflow_Step_Name__c=='Assessment Call' && objCWFS.APS_Workflow__c.contains('TSS')){
                        objCWFS.APS_Status__c=objCWFS.APS_Status__c;
                    }*/
                    else{
                        objCWFS.APS_Status__c=  system.label.PSP_CORE_Cancelled;
                    }
               /*** Start of Release: 3.0 AM Req #1019 ***/
               /*
                    System.debug(objCase.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c);
                if(cOBJ.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c != null){ 
                if(cOBJ.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c.equals('Inactive') && APS_Util_Constants.Adhoctaskcancel){ 
                    APS_Util_Constants.Adhoctaskcancel = false;
                    System.debug(objCase.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c );
                    taskToBeCancelled=[select id,Status,Subject from Task where WhatId=: objCase.Id where (Status!='Cancelled' AND Status!='Completed')];
                    if(!taskToBeCancelled.isEmpty() ){
                        for(Task cTask: taskToBeCancelled){
                            if(cTask.Subject != 'Adverse Event Follow-Up'){
                            cTask.status=system.label.PSP_CORE_Cancelled;
                        }
                        }
                    }
                }
                }
                /***  end of Release: 3.0 AM Req #1019 ***/
              
                System.debug('Case WorkflowSteps'+objCWFS.APS_Related_Object_SFDC_ID__c);                          
                if(objCWFS.APS_Related_Object_SFDC_ID__c!=null){
                    Task ObjTask = new Task(Id=objCWFS.APS_Related_Object_SFDC_ID__c);
                    objTask.Status=system.label.PSP_CORE_Cancelled;
                    objtask.APS_Skip_Validations__c = true;
                    objtask.PSP_CORE_r20_Activity_Stopped__c = True;
                    System.debug(objCase.PSP_CORE_r20_Infusion_Date__c);
                    System.debug(objCWFS.APS_Workflow_Step_Name__c);
                    system.debug(objCase.PSP_CORE_r20_Completion_of_Assessments__c);
                    System.debug(objCWFS.APS_Workflow__c);
                    System.debug(objCWFS.APS_Workflow__c.contains('TSS'));
                      if(
    ( (objCWFS.APS_Workflow_Step_Name__c== System.Label.PSP_CORE_r20_InfusionDateAssessmentCall)&& !(treatmentchange.contains('Stopped') || programchange.contains('Stop') || treatmentchange.contains('Interrupted Treatment') || programreason.contains('Reactive PSP Service')) && objCWFS.APS_Workflow__c.contains(System.Label.PSP_CORE_r20_Initialworkflowconsented))
        ||
        ((objCWFS.APS_Workflow_Step_Name__c==System.Label.PSP_CORE_r20_Assessment_Call) && !(treatmentchange.contains('Stopped') || programchange.contains('Stop') || treatmentchange.contains('Interrupted Treatment') || programreason.contains('Reactive PSP Service')) && objCWFS.APS_Workflow__c.contains(System.Label.PSP_CORE_r20_Initialworkflowconsented))
        ||
        ((objCWFS.APS_Workflow_Step_Name__c==System.Label.PSP_CORE_r20_WelcomePackCall) && !(treatmentchange.contains('Stopped') || programchange.contains('Stop') || treatmentchange.contains('Interrupted Treatment') || programreason.contains('Reactive PSP Service')) && objCWFS.APS_Workflow__c.contains(System.Label.PSP_CORE_r20_Initialworkflowconsented))
        ||
        ((objCWFS.APS_Workflow_Step_Name__c==System.Label.PSP_CORE_r20_WelcomeCall) && !(treatmentchange.contains('Stopped') || programchange.contains('Stop') || treatmentchange.contains('Interrupted Treatment') || programreason.contains('Reactive PSP Service')) && objCWFS.APS_Workflow__c.contains(System.Label.PSP_CORE_r20_Initialworkflowconsented))
        ){
                     System.debug('--in if---');                          
                    }
                    /*if(objCWFS.APS_Workflow_Step_Name__c=='Assessment Call' && objCWFS.APS_Workflow__c.contains('TSS')){
                     System.debug('--in if---');
                        }*/ 
                        else{
                        System.debug('-- in else---'+objtask);
                        lstTask.add(objtask);
                        System.debug('Tasks to be cancelled'+lstTask);
                    }
                    
                }
                
            }
           system.debug('lstCWFS+++'+lstCWFS);
           system.debug('lstCWFS+++'+lstTask); 
            if(lstTask != null){
             System.debug('Tasks to be cancelled Before Update'+lstTask);
             //APS_Util_Constants.OPTOUT_REC = False;
             System.debug('Run once'+APS_Util_Constants.OPTOUT_REC);
                Database.update(lstTask,false);
             System.debug('Tasks to be cancelled After Update'+lstTask);
            }
            if(!lstCWFS.IsEmpty()){
                Database.update(lstCWFS, false);
                //Database.update(lstTask,false);
            }
        
             System.debug('Tasks to be cancelled Before Update'+lstTask);
             
            
        }catch(Exception e){
            system.debug('Show Error'+e.getMessage());
        }
    }
           
    
    // Swithcing On Treatment and ProgramAffliation
/*Place for Documentation*/ 
    Public  void  SwitchObject(id localid,String Categetory)
    {
        
        
        
          system.debug('Called WFSnew method2');
        Try
        {
            String localCategory=Categetory;
            String localSubCategory = null;
            String localReason = null;
            String localSubReason = null;
            String localProgramid = null;
            String localProgramName=null;
            String localWorkflowID = null;
            String localWorkflowName = null;
            String localProgramStatus = null;
            String localTreatProgramReason = null;
            String localProgramISOTreatProgramReason = null;
            String localNextWF=null;
            Integer localdaysafterrestart = null;
            Integer daystreat = null;
            Decimal localdaysafterrestartprg = null;
            Decimal days = null;
            List<Case> caseList = new List<Case>();
            List<Task> tskList = new List<Task>();
            List<Task> updatedtskList = new List<Task>();
            
            system.debug('>>>>>>>>>>>>>1');
            if(Categetory=='Program'){
                PSP_CORE_Program_Affiliation__c currentProgramAffliation=[Select id,PSP_CORE_Program_Name__c,PSP_CORE_r20_Program_End_Date__c,PSP_CORE_r20_Program_Restart_Date__c,PSP_CORE_Program_Change__c,PSP_CORE_Program_Reason__c,PSP_CORE_Program_Sub_Reason__c,PSP_CORE_Program_Status__c,PSP_CORE_Program_Name__r.PSP_CORE_Country__c,PSP_CORE_r20_No_of_Days_after_Restart__c,PSP_CORE_Program_Name__r.Name,(select id,PSP_CORE_r20_Infusion_Number__c,PSP_CORE_Case_Restart__c,PSP_CORE_r20_Previous_WF__c from Cases__r) from  PSP_CORE_Program_Affiliation__c  where id=:localid limit 1]; 
                PSP_CORE_Program__c prg = [Select id, name from PSP_CORE_Program__c where id =: currentProgramAffliation.PSP_CORE_Program_Name__c];
               if(PSP_CORE_r20_Workflow_Restart__c.getValues(prg.Name)!=Null){
                  PSP_CORE_r20_Workflow_Restart__c res = PSP_CORE_r20_Workflow_Restart__c.getValues(prg.Name);
                  days = res.PSP_CORE_r20_No_of_Days_after_Restart__c;
                }
                //Moved this part to line no.131 -- Modified by Hari
                if(currentProgramAffliation!=NULL)
                {
                    system.debug('>>>>>>>>>>>>>2'+currentProgramAffliation);
                    localSubCategory=currentProgramAffliation.PSP_CORE_Program_Change__c;
                    localReason=currentProgramAffliation.PSP_CORE_Program_Reason__c;
                    localSubReason=currentProgramAffliation.PSP_CORE_Program_Sub_Reason__c;
                    localProgramName=prg.name;
                    if(localSubReason.equals('Return in Program') && localProgramName.equals('TSS')){
                        currentProgramAffliation.PSP_CORE_r20_Program_Restart_Date__c=system.today();
                    }
                    localProgramid=currentProgramAffliation.PSP_CORE_Program_Name__c;
                    localProgramStatus=currentProgramAffliation.PSP_CORE_Program_Status__c;
                    localTreatProgramReason =currentProgramAffliation.PSP_CORE_Program_Reason__c;
                    
                    //localdaysafterrestartprg = currentProgramAffliation.PSP_CORE_r20_No_of_Days_after_Restart__c;
                    //System.debug(currentProgramAffliation.PSP_CORE_r20_Program_End_Date__c);
                    if(currentProgramAffliation.PSP_CORE_r20_Program_End_Date__c != null && currentProgramAffliation.PSP_CORE_r20_Program_Restart_Date__c != null){
                    localdaysafterrestart=currentProgramAffliation.PSP_CORE_r20_Program_End_Date__c.daysBetween(currentProgramAffliation.PSP_CORE_r20_Program_Restart_Date__c);
                    system.debug('>>>>>>>>>>>>>localdaysafterrestart'+localdaysafterrestart);
                 //   localProgramCountry=PSP_CORE_Program_Name__r.PSP_CORE_Country__c;
                    }
                    system.debug('>>>>>>>>>>>>>Status'+currentProgramAffliation.PSP_CORE_Program_Status__c);
                    system.debug('>>>>>>>>>>>>>111111  In to Program trigger');
                    
                    if(localdaysafterrestart >= days && prg.name == 'TSS'){
                        localProgramISOTreatProgramReason = PSP_CORE_Map_CountryToISOCode__c.getinstance(currentProgramAffliation.PSP_CORE_Program_Name__r.PSP_CORE_Country__c).PSP_CORE_ISO_Code__c+'-'+currentProgramAffliation.PSP_CORE_Program_Name__r.Name+'-'+localTreatProgramReason+' Above One Year'; 
                        system.debug(localProgramISOTreatProgramReason+'localProgramISOTreatProgramReasonprg');                    
                       }
                    if(localdaysafterrestart < days && prg.name == 'TSS'){
                        // Addded by Naveen  -- Start
                         localProgramISOTreatProgramReason = PSP_CORE_Map_CountryToISOCode__c.getinstance(currentProgramAffliation.PSP_CORE_Program_Name__r.PSP_CORE_Country__c).PSP_CORE_ISO_Code__c+'-'+currentProgramAffliation.PSP_CORE_Program_Name__r.Name+'-'+localTreatProgramReason+' Below One Year'; 
                        // Addded by Naveen  -- End
                        for(Case cs : currentProgramAffliation.Cases__r){
                        if(localSubReason == 'Return in Program'){
                        cs.PSP_CORE_Case_Restart__c = True;
                        }
                        system.debug(cs.PSP_CORE_Case_Restart__c+'Restart checkbox On case');
                    tskList = [Select id, whatid,PSP_CORE_r20_Activity_Stopped__c from Task where whatid =: cs.id AND PSP_CORE_r20_Activity_Stopped__c = True];
                    if(localSubReason == 'Return in Program'){
                    localNextWF=cs.PSP_CORE_r20_Previous_WF__c;
                    system.debug(localNextWF+'localNextWFinprglessthan');
                    }
                         }
                    }
                }
            }
            if(!updatedtskList.isEmpty()){
                Update updatedtskList;
            }
            
            else if(Categetory=='Treatment')
            {       
               
                PSP_CORE_Treatment__c  currentTreatment=[Select  id,PSP_CORE_Treatment_Change__c,PSP_CORE_r20_Treatment_Restart_Date__c,PSP_CORE_r20_Treatment_End_Date__c,PSP_CORE_Treatment_Reason__c,PSP_CORE_Treatment_Sub_Reason__c,PSP_CORE_Program__c,PSP_CORE_r20_No_of_Days_after_Restart__c,PSP_CORE_Program_ID__c,PSP_CORE_Program__R.PSP_CORE_Program_Status__c,PSP_CORE_Program__r.PSP_CORE_Program_Reason__c,PSP_CORE_Program__r.Name from  PSP_CORE_Treatment__c   where PSP_CORE_Program__c=:localid limit 1]; 
                PSP_CORE_Program_Affiliation__c currentTreatProgramAffliation = [Select PSP_CORE_Program_Name__r.Name,id,PSP_CORE_Program_Name__c,PSP_CORE_Program_Change__c,PSP_CORE_Program_Reason__c,PSP_CORE_Program_Sub_Reason__c,PSP_CORE_Program_Status__c,PSP_CORE_Program_Name__r.PSP_CORE_Country__c,PSP_CORE_r20_No_of_Days_after_Restart__c,(select id,PSP_CORE_r20_Infusion_Number__c,PSP_CORE_r20_Previous_WF__c from Cases__r)   from  PSP_CORE_Program_Affiliation__c  where id=:currentTreatment.PSP_CORE_Program__c limit 1];
                PSP_CORE_Program__c prg = [Select id, name from PSP_CORE_Program__c where id =: currentTreatProgramAffliation.PSP_CORE_Program_Name__c];
                //Moved to Line no.202 by Hari
                 if(PSP_CORE_r20_Workflow_Restart__c.getValues(prg.Name)!=Null){
                PSP_CORE_r20_Workflow_Restart__c res = PSP_CORE_r20_Workflow_Restart__c.getValues(prg.Name);
                daystreat = Integer.valueof(res.PSP_CORE_r20_No_of_Days_after_Restart__c);
                
                }
                //daystreat = 365;
                if(currentTreatment!=NULL )
                {
                    
                    system.debug('>>>>>>>>>>>>>2'+currentTreatment);
                    system.debug(currentTreatment.PSP_CORE_r20_Treatment_End_Date__c);
                    localSubCategory=currentTreatment.PSP_CORE_Treatment_Change__c;
                    localReason=currentTreatment.PSP_CORE_Treatment_Reason__c;
                    localSubReason=currentTreatment.PSP_CORE_Treatment_Sub_Reason__c;
                    localProgramid=currentTreatment.PSP_CORE_Program_ID__c;
                    localProgramName=currentTreatment.PSP_CORE_Program__r.Name;
                    localProgramStatus=currentTreatment.PSP_CORE_Program__R.PSP_CORE_Program_Status__c;
                    localTreatProgramReason =currentTreatment.PSP_CORE_Program__r.PSP_CORE_Program_Reason__c;
                    if(localProgramName.equals('TSS')){
                        currentTreatment.PSP_CORE_r20_Treatment_Restart_Date__c = system.Today();
                    }
                    if(currentTreatment.PSP_CORE_r20_Treatment_Restart_Date__c != null && currentTreatment.PSP_CORE_r20_Treatment_End_Date__c != null){
                    localdaysafterrestart = currentTreatment.PSP_CORE_r20_Treatment_End_Date__c.daysBetween(currentTreatment.PSP_CORE_r20_Treatment_Restart_Date__c);
                    system.debug(localdaysafterrestart);
                    }
                    system.debug('>>>>>>>>>>>>>111111  In to Treatment trigger');
                
                }
                
                if(currentTreatProgramAffliation!=null && (prg.name == 'MS Care')){
                
                
                    localProgramISOTreatProgramReason = PSP_CORE_Map_CountryToISOCode__c.getinstance(currentTreatProgramAffliation.PSP_CORE_Program_Name__r.PSP_CORE_Country__c).PSP_CORE_ISO_Code__c+'-'+currentTreatProgramAffliation.PSP_CORE_Program_Name__r.Name+'-'+localTreatProgramReason;
                /*    if(currentTreatProgramAffliation.PSP_CORE_Program_Name__r.PSP_CORE_Country__c =='United Kingdom' ){
                       localProgramISOTreatProgramReason = 'GBR'+'-'++localTreatProgramReason;
                       }
                    else if(currentTreatProgramAffliation.PSP_CORE_Program_Name__r.PSP_CORE_Country__c =='Brazil' ){
                           localProgramISOTreatProgramReason = 'BRA'+'-'+localTreatProgramReason;
                       }  
                    else if(currentTreatProgramAffliation.PSP_CORE_Program_Name__r.PSP_CORE_Country__c =='Spain' ){
                           localProgramISOTreatProgramReason = 'ESP'+'-'+localTreatProgramReason;
                       } 
                    else if(currentTreatProgramAffliation.PSP_CORE_Program_Name__r.PSP_CORE_Country__c =='Belgium' ){
                           localProgramISOTreatProgramReason = 'BEL'+'-'+localTreatProgramReason;
                       } */
                }
                system.debug('treatmenttest'+currentTreatProgramAffliation+prg.name+localdaysafterrestart+days);
                system.debug(localdaysafterrestart);
                system.debug(daystreat);
                if(currentTreatProgramAffliation!=null && prg.name == 'TSS' && localdaysafterrestart >= daystreat){
                    system.debug('In Treatment Tss Restart program');
                    localProgramISOTreatProgramReason = PSP_CORE_Map_CountryToISOCode__c.getinstance(currentTreatProgramAffliation.PSP_CORE_Program_Name__r.PSP_CORE_Country__c).PSP_CORE_ISO_Code__c+'-'+currentTreatProgramAffliation.PSP_CORE_Program_Name__r.Name+'-'+localTreatProgramReason+' Above One Year';
                } else if(currentTreatProgramAffliation!=null && prg.name == 'TSS' && localdaysafterrestart < daystreat){
                     localProgramISOTreatProgramReason = PSP_CORE_Map_CountryToISOCode__c.getinstance(currentTreatProgramAffliation.PSP_CORE_Program_Name__r.PSP_CORE_Country__c).PSP_CORE_ISO_Code__c+'-'+currentTreatProgramAffliation.PSP_CORE_Program_Name__r.Name+'-'+localTreatProgramReason+' Below One Year';
                     for(Case cases:currentTreatProgramAffliation.Cases__r){
                     cases.PSP_CORE_Case_Restart__c = True;
                     tssRestartCheck=cases.PSP_CORE_Case_Restart__c;
                     system.debug(cases.PSP_CORE_Case_Restart__c+'Restart checkbox On case');
                    if(cases.PSP_CORE_r20_Previous_WF__c!=null && cases.PSP_CORE_r20_Previous_WF__c!=''){
                        localNextWF=cases.PSP_CORE_r20_Previous_WF__c;
                    }
                }
                }
                
              system.debug('12345localProgramISOTreatProgramReason '+localProgramISOTreatProgramReason);

            }
            
            if(localProgramStatus==system.label.PSP_CORE_Inactive)
            {
                Case currentCase= [select id ,PSP_CORE_Adherence_Outcome__c, RecordTypeId ,APS_Product__c,PSP_CORE_r20_Completion_of_Assessments__c, RecordType.developername , RecordType.Name , PSP_CORE_Program_Affiliation__c,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c,PSP_CORE_r20_Infusion_Date__c   from Case where PSP_CORE_Program_Affiliation__c=:localid and  (RecordType.developername=:system.label.PSP_CORE_Copaxone_Adherence or RecordType.developername=:system.label.PSP_CORE_Reslizumab_Adherence) limit 1] ;
                
                currentCase.PSP_CORE_Current_Workflow__c='';
                currentCase.PSP_CORE_Current_Workflow_ID__c='';
                currentCase.PSP_CORE_ReInvoke__c=false;
                currentCase.PSP_CORE_MAT_AdjustmentDays__c='';
                update currentCase;
                if(APS_Util_Constants.cancelworkflowcheck){
                ClanceWorkflow(currentCase);
                }
                        
            }
            else
            {
                  List<PSP_CORE_WorkFlow_Switch__c>  coreSwitchRecord=new List<PSP_CORE_WorkFlow_Switch__c>();
                  
                  system.debug('localCategory:'+localCategory);
                  system.debug('localSubCategory:'+localSubCategory);
                  system.debug('localReason:'+localReason);
                  system.debug('localSubReason:'+localSubReason);
                  system.debug('localProgramid:'+localProgramid);
                  system.debug('localdaysafterrestart:'+localdaysafterrestart);
                  system.debug('localNextWF: '+localNextWF);
               
                 
                 if(localProgramName.equals('TSS') && localNextWF!=null && localNextWF!='' && localSubCategory !='Interrupted Treatment' && localdaysafterrestart < 365){
                     coreSwitchRecord=[select id,PSP_CORE_Workflow_Action__c,PSP_CORE_Next_Flow__c,PSP_CORE_Second_Assigned_Workflow__c,PSP_CORE_Next_Flow__R.Name from  PSP_CORE_WorkFlow_Switch__c where 
                                                                PSP_CORE_Category__c=:localCategory and 
                                                                PSP_CORE_Sub_Category__c=:localSubCategory and                                                         
                                                                PSP_CORE_Reason__c=:localReason and
                                                                PSP_CORE_Sub_reason__c=:localSubReason and
                                                                PSP_CORE_Program__c=:localProgramid and
                                                                PSP_CORE_Next_Flow__c=:localNextWF LIMIT 50000];
                 } else {
                     
                     coreSwitchRecord=[select id,PSP_CORE_Workflow_Action__c,PSP_CORE_Next_Flow__c,PSP_CORE_Second_Assigned_Workflow__c,PSP_CORE_Next_Flow__R.Name from  PSP_CORE_WorkFlow_Switch__c where 
                                                                PSP_CORE_Category__c=:localCategory and 
                                                                PSP_CORE_Sub_Category__c=:localSubCategory and                                                         
                                                                PSP_CORE_Reason__c=:localReason and
                                                                PSP_CORE_Sub_reason__c=:localSubReason and
                                                                PSP_CORE_Program__c=:localProgramid LIMIT 50000];
                 }
                                                        
                                                                
                                                                
                
                system.debug('>>>>>>>>>>>>>3'+coreSwitchRecord);
                system.debug('>>>>>>>>>>>>>111111  In to switch');
                
                
                If(coreSwitchRecord[0]!=null && coreSwitchRecord.size()==1)
                {
                    localWorkflowID=coreSwitchRecord[0].PSP_CORE_Next_Flow__c;
                    localWorkflowName=coreSwitchRecord[0].PSP_CORE_Next_Flow__R.Name;
                    if(coreSwitchRecord[0].PSP_CORE_Workflow_Action__c==system.label.PSP_CORE_START)
                    {
                        List<Case> lstCase= [select id ,PSP_CORE_Adherence_Outcome__c,PSP_CORE_r20_Completion_of_Assessments__c, RecordTypeId ,APS_Product__c, RecordType.developername , RecordType.Name , PSP_CORE_Program_Affiliation__c,PSP_CORE_r20_Infusion_Date__c,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c  from Case where PSP_CORE_Program_Affiliation__c=:localid and  (RecordType.developername=:system.label.PSP_CORE_Copaxone_Adherence or RecordType.developername=:system.label.PSP_CORE_Reslizumab_Adherence) limit 1] ;
                        if(!lstCase.isEmpty())
                        {
                          if(lstCase[0].PSP_CORE_Current_Workflow_ID__c!=localWorkflowID){
                              if(APS_Util_Constants.cancelworkflowcheck){
                             ClanceWorkflow(lstCase[0]);
                              }
                            PSP_CORE_Workflow_Switch_Helper objWSH = new PSP_CORE_Workflow_Switch_Helper();
                            system.debug('case - workflow'+lstCase[0].Id+localWorkflowID);
                            UpdatingCurrentWorkflowIdInCase(lstCase[0].Id,localWorkflowName, localWorkflowID);
                            objWSH.switchWorkflowStepsToCases(lstCase[0].Id,localWorkflowID);                            
                            system.debug('Calling WFSH from WSNEW 1');
                            }
                        }
                    
                    
                    }
                    
                    else if(coreSwitchRecord[0].PSP_CORE_Workflow_Action__c==system.label.PSP_CORE_Cancel)
                    {
                        List<Case> lstCase= [select id ,PSP_CORE_Adherence_Outcome__c,PSP_CORE_r20_Completion_of_Assessments__c, RecordTypeId ,APS_Product__c, RecordType.developername , RecordType.Name , PSP_CORE_Program_Affiliation__c,PSP_CORE_r20_Infusion_Date__c from Case where PSP_CORE_Program_Affiliation__c=:localid and  (RecordType.developername=:system.label.PSP_CORE_Copaxone_Adherence or RecordType.developername=:system.label.PSP_CORE_Reslizumab_Adherence) limit 1] ;
                        if(!lstCase.isEmpty())
                        {
                            if(APS_Util_Constants.cancelworkflowcheck){
                            ClanceWorkflow(lstCase[0]);
                            }
                            Case TempCase= lstCase[0];
                             TempCase.PSP_CORE_Current_Workflow__c='';
                            TempCase.PSP_CORE_Current_Workflow_ID__c='';
                            TempCase.PSP_CORE_ReInvoke__c=false;
                            update TempCase;
                        }
                    
                    
                    }
                    else if(coreSwitchRecord[0].PSP_CORE_Workflow_Action__c==system.label.PSP_CORE_Change)
                    {
                       system.debug('>>>>>>>>>>>>>4'+coreSwitchRecord[0].PSP_CORE_Workflow_Action__c+'>>>>>>'+localProgramid );
                        List<Case> lstCase= [select id ,PSP_CORE_Case_Restart__c,PSP_CORE_Adherence_Outcome__c,PSP_CORE_r20_Completion_of_Assessments__c,PSP_CORE_r20_Infusion_Date__c,RecordTypeId ,APS_Product__c, RecordType.developername , RecordType.Name , PSP_CORE_Program_Affiliation__c,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c from Case where PSP_CORE_Program_Affiliation__c=:localid and  (RecordType.developername=:system.label.PSP_CORE_Copaxone_Adherence or RecordType.developername=:system.label.PSP_CORE_Reslizumab_Adherence) limit 1] ;
                        system.debug('>>>>>>>>>>>>>5'+lstCase);
                        
                        if(!lstCase.isEmpty())
                        {
                           
                             if(lstCase[0].PSP_CORE_Current_Workflow_ID__c!=localWorkflowID || (localProgramISOTreatProgramReason.contains('TSS-PSP Service Below One Year') && lstCase[0].PSP_CORE_r20_Infusion_Date__c!=null) || localProgramISOTreatProgramReason.contains('TSS-Reactive PSP Service'))
                            { 
                                 UpdatingCurrentWorkflowIdInCase(lstCase[0].Id,localWorkflowName, localWorkflowID);
                                APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch=false;
                                if(APS_Util_Constants.cancelworkflowcheck){
                                ClanceWorkflow(lstCase[0]);
                                }
                                PSP_CORE_Workflow_Switch_Helper objWSH = new PSP_CORE_Workflow_Switch_Helper();
                                objWSH.switchWorkflowStepsToCases(lstCase[0].Id,localWorkflowID);                               
                                system.debug('>>>>>>>>>>>>>111111  In to switch calling helper');
                                system.debug('Calling WFSH from WSNEW 2');
                                
                                 // APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch=false;
                            }
                        }
                    }
                
                }
                
                if(coreSwitchRecord.size()>1){
                   For(PSP_CORE_WorkFlow_Switch__c coreSwitchObj : coreSwitchRecord){
                   
                    system.debug('localProgramISOTreatProgramReason:'+localProgramISOTreatProgramReason);
                    system.debug('coreSwitchObj.PSP_CORE_Next_Flow__r.name:'+coreSwitchObj.PSP_CORE_Next_Flow__r.name);
                    //system.debug('currentworkflow'+PSP_CORE_r13_PSP_RePSP_Restart_Workflow__c.getinstance(localProgramISOTreatProgramReason).PSP_CORE_r13_Workflow_Name__c);
                      if(PSP_CORE_r13_PSP_RePSP_Restart_Workflow__c.getinstance(localProgramISOTreatProgramReason).PSP_CORE_r13_Workflow_Name__c != null && PSP_CORE_r13_PSP_RePSP_Restart_Workflow__c.getinstance(localProgramISOTreatProgramReason).PSP_CORE_r13_Workflow_Name__c == coreSwitchObj.PSP_CORE_Next_Flow__r.name ){
                      system.debug('coreSwitchObj.PSP_CORE_Workflow_Action__c:'+coreSwitchObj.PSP_CORE_Workflow_Action__c);
                     string  localWorkflowID1=coreSwitchObj.PSP_CORE_Next_Flow__c;
                     string  localWorkflowName1=coreSwitchObj.PSP_CORE_Next_Flow__R.Name;  
                     if(coreSwitchObj.PSP_CORE_Workflow_Action__c==system.label.PSP_CORE_Change){
                       system.debug('>>>>>>>>>>>>>4'+coreSwitchObj.PSP_CORE_Workflow_Action__c+'>>>>>>'+localProgramid );
                        List<Case> lstCase= [select id ,PSP_CORE_Adherence_Outcome__c,PSP_CORE_r20_Completion_of_Assessments__c, RecordTypeId ,APS_Product__c, RecordType.developername , RecordType.Name , PSP_CORE_Program_Affiliation__c,PSP_CORE_r20_Infusion_Date__c,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c  from Case where PSP_CORE_Program_Affiliation__c=:localid and  (RecordType.developername=:system.label.PSP_CORE_Copaxone_Adherence or RecordType.developername=:system.label.PSP_CORE_Reslizumab_Adherence) limit 1] ;
                        system.debug('>>>>>>>>>>>>>5'+lstCase);
                        
                        if(!lstCase.isEmpty())
                        {
                           system.debug('>>>>>>>>>>>>>5234'+lstCase[0].PSP_CORE_Current_Workflow_ID__c+'@@@'+localWorkflowID1);
                            if(lstCase[0].PSP_CORE_Current_Workflow_ID__c!=localWorkflowID1)
                            { 
                                 system.debug('>>>>>>>>>>>>>111111  In to switch calling helper');
                                 UpdatingCurrentWorkflowIdInCase(lstCase[0].Id,localWorkflowName1, localWorkflowID1);
                                 system.debug('Calling 12');
                                APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch=false;
                                if(APS_Util_Constants.cancelworkflowcheck){
                                ClanceWorkflow(lstCase[0]);
                                }
                               system.debug('Calling 12');
                                PSP_CORE_Workflow_Switch_Helper objWSH = new PSP_CORE_Workflow_Switch_Helper();
                                objWSH.switchWorkflowStepsToCases(lstCase[0].Id,localWorkflowID1);
                                system.debug('Calling WFSH from WSNEW 3');
                                system.debug('>>>>>>>>>>>>>111111  In to switch calling helper');
                                
                                 // APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch=false;
                            }
                        }
                       }
                                     
                      }
                   }
                
                
                }
                
                
                
                
            }
        }catch(exception e)
        {
            system.debug('Show Error'+e.getMessage());
        }
    }
    
   
    
    
    
    
// swithching Based on the case object
/*Place for Documentation*/
    Public void  SwitchObjectCaseAndTask(id localid,String Categetory)
    {
          system.debug('Called WFSnew method3');
        try{
            String localCategory=Categetory;
            String localSubCategory = null;
            String localReason = null;
            String localSubReason = null;
            String localProgramid = null;
            String localWorkflowID = null;
            String localWorkflowName = null;
            String localWorkflowAction = null;
            String localdaysafterrestart = null;

            system.debug('>>>>>>>>>>>>>1');
            if(Categetory==system.label.PSP_CORE_Case)
            {
                Case currentCase=[select id,PSP_CORE_Adherence_Outcome__c,PSP_CORE_Program_ID__c,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c,PSP_CORE_Case_Restart__c,PSP_CORE_Program_Affiliation__c,PSP_CORE_Program_Affiliation__r.name,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Sub_Reason__c,PSP_CORE_r20_Infusion_Date__c,PSP_CORE_r20_Completion_of_Assessments__c,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c  from Case where id=:localid LIMIT 50000];
                //Added by Naveen R2.0 D-994  -- Start
                PSP_CORE_Program__c program=[SELECT PSP_CORE_Country__c, CreatedById, CreatedDate, IsDeleted, LastModifiedById, LastModifiedDate, OwnerId, Name, Id, SystemModstamp FROM PSP_CORE_Program__c where id=:currentCase.PSP_CORE_Program_ID__c limit 1];
                PSP_CORE_Treatment__c Treatment=[Select id,PSP_CORE_Treatment_Change__c,PSP_CORE_Treatment_Reason__c,PSP_CORE_Treatment_Sub_Reason__c,PSP_CORE_Program__c,PSP_CORE_Program_ID__c    from  PSP_CORE_Treatment__c   where PSP_CORE_Program__c=:currentCase.PSP_CORE_Program_Affiliation__c limit 50];
                string treatchange = Treatment.PSP_CORE_Treatment_Change__c;
                string prgchange = currentCase.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Sub_Reason__c;
                //Added by Naveen R2.0 D-994  -- E
                if(currentCase!=NULL)
                {
                    system.debug('>>>>>>>>>>>>>2');
                    localSubCategory='Adherence Support Program';
                    localReason=currentCase.PSP_CORE_Adherence_Outcome__c;
                    localProgramid=currentCase.PSP_CORE_Program_ID__c;
                    
                   
                
                }
                
                list<PSP_CORE_WorkFlow_Switch__c>  coreSwitchRecord=[select id,PSP_CORE_Workflow_Action__c,PSP_CORE_Next_Flow__c,PSP_CORE_Second_Assigned_Workflow__c,PSP_CORE_Next_Flow__R.Name from  PSP_CORE_WorkFlow_Switch__c where 
                                                                PSP_CORE_Sub_Category__c=:localSubCategory and 
                                                                PSP_CORE_Reason__c=:localReason and                                                         
                                                                PSP_CORE_Program__c=:localProgramid LIMIT 50000];
                                                                
                                                                
                                                                
                 system.debug('>>>>>>>>>>>>>3'+coreSwitchRecord);    
                If(coreSwitchRecord!=null && coreSwitchRecord.size()>0)
                {
                    for(integer i=0;i<coreSwitchRecord.size();i++)
                    {
                        PSP_Case_Restart_Execute_Flows__c restartExecuteFlow=PSP_Case_Restart_Execute_Flows__c.getValues(coreSwitchRecord[i].PSP_CORE_Next_Flow__R.Name);   
                        system.debug('outloopwid'+restartExecuteFlow.PSP_Workflow_Execution__c);
                        
                        if(currentCase.PSP_CORE_Case_Restart__c==true)
                        {
                            if(currentCase.PSP_CORE_Program_Affiliation__r.name.equals('TSS') && restartExecuteFlow.PSP_Workflow_Execution__c=='Initial'){
                                localWorkflowID=coreSwitchRecord[i].PSP_CORE_Next_Flow__c;
                                localWorkflowName=coreSwitchRecord[i].PSP_CORE_Next_Flow__R.Name; 
                                localWorkflowAction=coreSwitchRecord[i].PSP_CORE_Workflow_Action__c; 
                                break;
                            }
                            if(restartExecuteFlow.PSP_Workflow_Execution__c==system.label.PSP_CORE_Restart)
                            {
                                localWorkflowID=coreSwitchRecord[i].PSP_CORE_Next_Flow__c;
                                localWorkflowName=coreSwitchRecord[i].PSP_CORE_Next_Flow__R.Name; 
                                localWorkflowAction=coreSwitchRecord[i].PSP_CORE_Workflow_Action__c; 
                                break;
                             
                            }
                            
                                    
                        
                        }
                        else
                        {
                        
                        
                        
                                if(restartExecuteFlow.PSP_Workflow_Execution__c=='Initial')
                                {
                                   system.debug('inloopwid'+coreSwitchRecord[i].PSP_CORE_Next_Flow__c);

                                    localWorkflowID=coreSwitchRecord[i].PSP_CORE_Next_Flow__c;
                                    localWorkflowName=coreSwitchRecord[i].PSP_CORE_Next_Flow__R.Name; 
                                    localWorkflowAction=coreSwitchRecord[i].PSP_CORE_Workflow_Action__c; 
                                    break;
                                 
                                }
                        
                        }
                    }
                        
                        
                        
                }
                system.debug('localWorkflowID:'+localWorkflowID);
                system.debug('localWorkflowName:'+localWorkflowName);
                system.debug('localWorkflowAction:'+localWorkflowAction);
                system.debug('localWorkflowAction:'+localWorkflowAction);
                system.debug('system.label.PSP_CORE_Change:'+system.label.PSP_CORE_Change);
                system.debug('system.label.PSP_CORE_Change:'+currentCase.PSP_CORE_Current_Workflow_ID__c);
                system.debug('system.label.PSP_CORE_Change:'+localWorkflowID);
                system.debug('Treat Change'+treatchange);                     
                if(localWorkflowAction==system.label.PSP_CORE_Change)
                {
                   //ystem.debug('>>>>>>>>>>>>>4'+coreSwitchRecord); 
                  // system.debug('>>>>>>>>>>>>>4'+coreSwitchRecord.PSP_CORE_Workflow_Action__c+'>>>>>>'+localProgramid );
                   if(program.name.equals('TSS') && currentCase.PSP_CORE_r20_Infusion_Date__c==null){
                       if(APS_Util_Constants.cancelworkflowcheck){
                       ClanceWorkflow(currentCase);
                       }
                       if(currentCase.PSP_CORE_Current_Workflow_ID__c==localWorkflowID)
                       {
                           UpdatingCurrentWorkflowIdInCase(currentCase.Id,localWorkflowName, localWorkflowID);
                         system.debug('Calling WFSH from WSNEW 4'+currentCase.Id+' '+localWorkflowID);
                        PSP_CORE_Workflow_Switch_Helper objWSH = new PSP_CORE_Workflow_Switch_Helper();
                        APS_PreventRecursion_Helper.PreventProgramWorkflowRecusive=false;
                         APS_PreventRecursion_Helper.PreventCaseWorkflowsRecusive=false;
                         APS_PreventRecursion_Helper.PreventTreatWorkflowsRecusive=false;
                        objWSH.switchWorkflowStepsToCases(currentCase.Id,localWorkflowID);
                       }
                   }
                   else  if(currentCase.PSP_CORE_Current_Workflow_ID__c!=localWorkflowID || (currentCase.PSP_CORE_Current_Workflow_ID__c==localWorkflowID && treatchange == 'Restart Treatment') || (currentCase.PSP_CORE_Current_Workflow_ID__c==localWorkflowID && prgchange == 'Return in Program'))
                    {
                        if(APS_Util_Constants.cancelworkflowcheck){
                        ClanceWorkflow(currentCase);
                        }
                         UpdatingCurrentWorkflowIdInCase(currentCase.Id,localWorkflowName, localWorkflowID);
                         system.debug('Calling WFSH from WSNEW 4'+currentCase.Id+' '+localWorkflowID);
                        PSP_CORE_Workflow_Switch_Helper objWSH = new PSP_CORE_Workflow_Switch_Helper();
                        APS_PreventRecursion_Helper.PreventProgramWorkflowRecusive=false;
                         APS_PreventRecursion_Helper.PreventCaseWorkflowsRecusive=false;
                         APS_PreventRecursion_Helper.PreventTreatWorkflowsRecusive=false;
                        objWSH.switchWorkflowStepsToCases(currentCase.Id,localWorkflowID);
                        
                        system.debug('Calling WFSH from WSNEW 4');
                       
                       // APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch=false;
                    }
                   
                }
            }
        }catch(Exception e){
            system.debug('Show Error'+e.getMessage());
        }
    }
        
     
    
   
    // Task Creatation 
/*Place for Documentation*/ 
    Public  void  SwitchObjectTaskCreation(id localid,String Categetory)
    {
          system.debug('Called WFSnew method4');
        try{
            List<String> localCategory=new List<String>();
            List<String> localSubCategory=new List<String>();
            List<String>  localReason=new List<String>();
            List<String>  localSubReason=new List<String>();
            List<String> localProgramid=new List<String>();
            List<String> localStart=new List<String>();
            List<String> localdaysafterrestart=new List<String>();
            Integer nextKey = 0;
            String localWorkflowID = null;
            String localWorkflowName = null;
            
            
            list<PSP_CORE_Treatment__c>  treatmentList=new  list<PSP_CORE_Treatment__c>();
            PSP_CORE_Program_Affiliation__c programAffliationList=new PSP_CORE_Program_Affiliation__c();
            system.debug('>>>>>>>>>>>>>1');
            
            
            if(Categetory==system.label.PSP_CORE_Case)
            {
                Case currentCase=[select id,PSP_CORE_Adherence_Outcome__c,PSP_CORE_Program_ID__c,PSP_CORE_Program_Affiliation__c ,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c   from Case where id=:localid LIMIT 50000];
                 system.debug('>>>>>>>>>>>>>2');
                
                if(currentCase!=NULL)
                {
                    if(currentCase.PSP_CORE_Program_Affiliation__c!=null)
                    {
                    
                        system.debug('>>>>>>>>>>>>>3');
                        // Commented Because case creation is based on the program .Doesn't require on the treatment.
                        /*TreatmentList=[Select id,Treatment_Change__c,PSP_CORE_Treatment_Reason__c,PSP_CORE_Treatment_Sub_Reason__c,PSP_CORE_Program__c,PSP_CORE_Program_ID__c    from  PSP_CORE_Treatment__c   where PSP_CORE_Program__c=:currentCase.PSP_CORE_Program_Affiliation__c limit 50]; 
                        if(TreatmentList.size()>0)
                        {
                        
                             system.debug('>>>>>>>>>>>>>4');
                            system.debug('>>>>>>>>TreatMens'+TreatmentList);
                            for(integer i=0;i<TreatmentList.size()-1;i++)
                            {
                                 system.debug('>>>>>>>>TreatMens'+TreatmentList[i]);
                                localCategory.add('Treatment');
                                localSubCategory.add(TreatmentList[i].Treatment_Change__c);
                                localReason.add(TreatmentList[i].PSP_CORE_Treatment_Reason__c);
                                localSubReason.add(TreatmentList[i].PSP_CORE_Treatment_Sub_Reason__c);
                                localProgramid.add(TreatmentList[i].PSP_CORE_Program_ID__c);
                                localStart.add('Start');
                                nextKey=i;
                                system.debug('>>>>>>>>>>>>>5  nextKey'+nextKey);
                                
                            }
                        }*/
                        
                        
                        
                        
                        
                       
                    
                         
                        ProgramAffliationList=[Select id,PSP_CORE_Program_Name__c,PSP_CORE_Program_Change__c,PSP_CORE_Program_Reason__c,PSP_CORE_Program_Sub_Reason__c from  PSP_CORE_Program_Affiliation__c  where id=:currentCase.PSP_CORE_Program_Affiliation__c limit 1];
                        if(ProgramAffliationList!=null)
                        {
                            system.debug('>>>>>>>>>>>>>6');
                            system.debug('>>>>>>>>Programs'+ProgramAffliationList);
                            system.debug('>>>>>>>>localSubCategory'+localSubCategory);
                            localSubCategory.add(ProgramAffliationList.PSP_CORE_Program_Change__c);
                            localCategory.add('Program');
                            system.debug('>>>>>>>>localCategory'+localCategory);
                            localReason.add(ProgramAffliationList.PSP_CORE_Program_Reason__c);
                            localSubReason.add(ProgramAffliationList.PSP_CORE_Program_Sub_Reason__c);
                            localProgramid.add(ProgramAffliationList.PSP_CORE_Program_Name__c);
                            localStart.add(system.label.PSP_CORE_START);
                            //localdaysafterrestart.add(ProgramAffliationList.PSP_CORE_r20_Restart_Days__c);
                        }
                
                    
                    }
                }
                
                           system.debug('<<<<<<cat'+localCategory);
                             system.debug('<<<<<<Reason'+localReason);
                             system.debug('<<<<<<SubRea'+localSubReason);
                              system.debug('<<<<<<start'+localStart);
                 
                            
                             
                        
                 
                
                
                LIst<PSP_CORE_WorkFlow_Switch__c>  coreSwitchRecordList=[select id,PSP_CORE_Workflow_Action__c,PSP_CORE_Next_Flow__c,PSP_CORE_Next_Flow__R.Name,PSP_CORE_Second_Assigned_Workflow__c from  PSP_CORE_WorkFlow_Switch__c where 
                                                                PSP_CORE_Sub_Category__c IN: localSubCategory and 
                                                                PSP_CORE_Reason__c IN : localReason and                                                         
                                                                PSP_CORE_Program__c IN : localProgramid and 
                                                                PSP_CORE_Workflow_Action__c in: localStart LIMIT 50000];
                                                                
                                                                
                 system.debug('>>>>>>>>>>>>>7'+coreSwitchRecordList);    
                
                
                
                
                If(coreSwitchRecordList.size()>0)
                {
                
                    for(integer i=0;i<coreSwitchRecordList.size();i++)
                    {
                        
                            localWorkflowID=coreSwitchRecordList[i].PSP_CORE_Next_Flow__c;
                            localWorkflowName=coreSwitchRecordList[i].PSP_CORE_Next_Flow__R.Name;
                            break;
                            
                       
                    
                    }
                    
                                                      
                    system.debug('>>>>>>>>>>>>>7'+localWorkflowID);  
                    if(APS_Util_Constants.cancelworkflowcheck){
                    ClanceWorkflow(currentCase);
                    }
                     UpdatingCurrentWorkflowIdInCase(currentCase.Id,localWorkflowName, localWorkflowID);
                    PSP_CORE_Workflow_Switch_Helper objWSH = new PSP_CORE_Workflow_Switch_Helper();
                    objWSH.switchWorkflowStepsToCases(currentCase.Id,localWorkflowID);
                    system.debug('Calling WFSH from WSNEW 5');
                   
                    //APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch=false;
                     
                }
                    
            }   
        }catch(Exception e){
            system.debug('Show Error'+e.getMessage());
        }
     
    }
    
    
    //InterChnage  between the  standard Or Intensive
    /*Place for Documentation*/
    Public void  SwitchBetweenIntensiveAndStandard(id localid,String Categetory,String Adjustment)
    {
          system.debug('Called WFSnew method5');
        try{
            String localCategory=Categetory;
            String localSubCategory = null;
            String localReason = null;
            String localSubReason = null;
            String localProgramid = null;
            String localWorkflowID = null;
            String localWorkflowName = null;
            String localWorkflowAction = null;
            integer sequence;
            Double  localAdjustment = Double.valueof(Adjustment);   
            system.debug('>>>>>>>>>>>>>7');
            if(Categetory==system.label.PSP_CORE_Case)
            {
                Case currentCase=[select id,PSP_CORE_Adherence_Outcome__c,PSP_CORE_r20_Completion_of_Assessments__c,PSP_CORE_Program_ID__c,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c,PSP_CORE_Case_Restart__c,PSP_CORE_r20_Infusion_Date__c,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c from Case where id=:localid LIMIT 50000];
                if(currentCase!=NULL)
                {
                    system.debug('>>>>>>>>>>>>>2');
                    localSubCategory='Adherence Support Program';
                    localReason=currentCase.PSP_CORE_Adherence_Outcome__c;
                    localProgramid=currentCase.PSP_CORE_Program_ID__c;
                   
                
                }
                
                list<PSP_CORE_WorkFlow_Switch__c>  coreSwitchRecord=[select id,PSP_CORE_Workflow_Action__c,PSP_CORE_Next_Flow__c,PSP_CORE_Second_Assigned_Workflow__c,PSP_CORE_Next_Flow__R.Name from  PSP_CORE_WorkFlow_Switch__c where 
                                                                PSP_CORE_Sub_Category__c=:localSubCategory and 
                                                                PSP_CORE_Reason__c=:localReason and                                                         
                                                                PSP_CORE_Program__c=:localProgramid LIMIT 50000];
                                                                
                                                                
                                                                
                 system.debug('>>>>>>>>>>>>>8'+coreSwitchRecord);    
                If(coreSwitchRecord!=null && coreSwitchRecord.size()>0)
                {
                    for(integer i=0;i<coreSwitchRecord.size();i++)
                    {
                    
                         system.debug('>>>>>>>>>>>>>NAME'+coreSwitchRecord[i].PSP_CORE_Next_Flow__R.Name);
                        PSP_Case_Restart_Execute_Flows__c restartExecuteFlow=PSP_Case_Restart_Execute_Flows__c.getValues(coreSwitchRecord[i].PSP_CORE_Next_Flow__R.Name);   
                       system.debug('>>>>>>>>>>>>>csVALUE'+restartExecuteFlow);
                       system.debug('inloop@@@value'+currentCase.PSP_CORE_Case_Restart__c);
                        if(currentCase.PSP_CORE_Case_Restart__c==true)
                        {
                             system.debug('>>>>>>>>>>>>>9');    
                            if(restartExecuteFlow.PSP_Workflow_Execution__c=='Restart')
                            {
                            system.debug('inloop@@@');
                            
                                localWorkflowID=coreSwitchRecord[i].PSP_CORE_Next_Flow__c;
                                localWorkflowName=coreSwitchRecord[i].PSP_CORE_Next_Flow__R.Name; 
                                localWorkflowAction=coreSwitchRecord[i].PSP_CORE_Workflow_Action__c; 
                                break;
                                }
                            
                                    
                        
                        }
                        else
                        {
                                if(restartExecuteFlow.PSP_Workflow_Execution__c=='Initial')
                                {
                                    system.debug('>>>>>>>>>>>>>10'); 
                                    localWorkflowID=coreSwitchRecord[i].PSP_CORE_Next_Flow__c;
                                    localWorkflowName=coreSwitchRecord[i].PSP_CORE_Next_Flow__R.Name; 
                                    localWorkflowAction=coreSwitchRecord[i].PSP_CORE_Workflow_Action__c; 
                                    break;
                                 
                                }
                        
                        }
                    }
    
                }
                                 
                if(localWorkflowAction==system.label.PSP_CORE_Change)
                {         
                    system.debug('>>>>>>>>>>>>>10'); 
                    List<APS_Workflow_Steps__c>  listNextWorkflowseq=[select id,APS_Sequence__c from APS_Workflow_Steps__c   where APS_Workflow_Master__c=:localWorkflowID and APS_Due_Date_Adjustment__c <=: LocalAdjustment Order by APS_Sequence__c DESC Limit 1]; 
                    if(listNextWorkflowseq.isEmpty()){
                        sequence=1;
                    }else{
                        sequence=Integer.valueOf(listNextWorkflowseq[0].APS_Sequence__c)+1;
                    }
                    if(currentCase.PSP_CORE_Current_Workflow_ID__c!=localWorkflowID)
                    {
                        system.debug('>>>>>>>>>>>>>11'+sequence); 
                        if(APS_Util_Constants.cancelworkflowcheck){ 
                        ClanceWorkflow(currentCase);
                        }
                        UpdatingCurrentWorkflowIdInCase(currentCase.Id,localWorkflowName, localWorkflowID);
                        PSP_CORE_Workflow_Switch_Helper objWSH = new PSP_CORE_Workflow_Switch_Helper();
                        objWSH.switchWorkflowAnnualStepsToCases(currentCase.id,localWorkflowID,sequence);
                        
                        //APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch=false;
                    }
                   
                }
            }
        }catch(Exception e){
            system.debug('Show Error'+e.getMessage());
        }
    }
        
 
    // For updating workfolwid reinvoke
    /*Place for Documentation*/
    Public Void UpdatingCurrentWorkflowIdInCase(id caseid,String WorkflowName,string Workflowid )
    {
          system.debug('Called WFSnew method6');
          system.debug('--recur check---'+APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch);
        try {
            
            if(APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch)
            {
            
                Case currentCase=[select id,PSP_CORE_Case_Restart__c,PSP_CORE_r20_Previous_WF__c,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c,PSP_CORE_ReInvoke__c   from Case where id=:caseid LIMIT 50000];
                //Added by Naveen -- Start
               if(WorkflowName.contains('Initial Workflow - Consented')){
                    currentCase.PSP_CORE_r20_Previous_WF__c=Workflowid;
                }
                //Added by Naveen -- Stop
                try{
                system.debug('WorkflowName'+WorkflowName);
                PSP_Case_Restart_WorkFlow__c caseRestartWorkflowRecord = PSP_Case_Restart_WorkFlow__c.getValues(WorkflowName);
                system.debug(caseRestartWorkflowRecord+'caseRestartWorkflowRecord');
                if(caseRestartWorkflowRecord!=null)
                {   
                    system.debug('Restart Checkbox'+currentCase.PSP_CORE_Case_Restart__c);
                    currentCase.PSP_CORE_Case_Restart__c=true;
                    system.debug('Restart Checkbox'+currentCase.PSP_CORE_Case_Restart__c);
                    
                }
                } Catch(Exception e){
                }
                
                //currentCase.PSP_CORE_r20_Previous_WF__c = currentCase.PSP_CORE_Current_Workflow_ID__c;   
                currentCase.PSP_CORE_Current_Workflow__c=WorkflowName;
                currentCase.PSP_CORE_Current_Workflow_ID__c=Workflowid;
                currentCase.PSP_CORE_ReInvoke__c=false;
                system.debug('Restart Check'+tssRestartCheck);
                if(tssRestartCheck){ 
                    system.debug('Restart Check'+tssRestartCheck);
                    currentCase.PSP_CORE_Case_Restart__c=tssRestartCheck;                    
                }
                update currentCase;
                 system.debug('Called WFSnew method6'+currentCase);
            }   
            
        }catch(Exception e) {}
    }
    
    
    
    // For Reinvoke workflow steps after completion of annual steps
    /*Place for Documentation*/
    Public void ReinvokeforCaseWorkflow(id CaseID,Id CWFSId)
    {
          system.debug('Called WFSnew method7');
        try
        {
            system.debug('>>>>>>>>>>Reinvoke1');
        
            Case currentCase=[select id,PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c,PSP_CORE_ReInvoke__c   from Case where id=:CaseID LIMIT 50000];
            if(currentCase!=null)
            {
                system.debug('>>>>>>>>>>Reinvoke2');
                if(currentCase.PSP_CORE_ReInvoke__c==True)
                {
                    system.debug('>>>>>>>>>>Reinvoke3');
                    List<APS_Case_Workflow_Step__c> listOfCaseWorkflowSteps=[select id,PSP_CORE_ReInvoke__c,APS_Status__c from APS_Case_Workflow_Step__c where APS_Related_Case__c=:CaseID and APS_Workflow_Id__c=:CWFSId and APS_Status__c   NOT IN (:system.label.PSP_CORE_WorkflowSwitch_Completed, :System.label.PSP_CORE_WorkflowSwitch_Cancelled) limit 3 ]; 
                    if(listOfCaseWorkflowSteps.size()==0)
                    {
                        system.debug('>>>>>>>>>>Reinvoke4');
                        PSP_CORE_Workflow_Switch_Helper   objWFS=new PSP_CORE_Workflow_Switch_Helper();
                        ObjWFS.swithReinvokeWorkflow(CaseID,CWFSId);
                       // APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch=false;
                        system.debug('>>>>>>>>>>>>>111111  In to reinvoke trigger');
                    
                    
                    }
                    
                
                }


            }
        }catch(Exception e){
            system.debug('Show Error'+e.getMessage());
        }
    }
    
    
    
     // Restarting Same workflow Based on the Moriskey assessment for Restart initial workflows
     /*Place for Documentation*/
    Public void  MoriskyOLDWorkflow(id localid,String Categetory)
    {   
         system.debug('Called WFSnew method8');
        try{
            String localCategory=Categetory;
            String localSubCategory = null;
            String localReason = null;
            String localSubReason = null;
            String localProgramid = null;
            String localWorkflowID = null;
            String localWorkflowName = null;
            String localWorkflowAction = null;

            System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial3');
            if(Categetory==system.label.PSP_CORE_Case)
            {
                System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial4');
                set<string> statusLsit=new set<string>{System.Label.PSP_CORE_WorkflowSwitch_In_Progress,System.Label.PSP_CORE_WorkflowSwitch_Not_Started,System.Label.PSP_CORE_WorkflowSwitch_Waiting,System.Label.PSP_CORE_WorkflowSwitch_Assigned,System.Label.PSP_CORE_WorkflowSwitch_Not_Assigned};
                Case currentCase=[select id,PSP_CORE_Adherence_Outcome__c,PSP_CORE_Program_ID__c,(select id,status from Tasks where Status IN :statusLsit )PSP_CORE_Current_Workflow__c,PSP_CORE_Current_Workflow_ID__c,PSP_CORE_Case_Restart__c,PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c   from Case where id=:localid LIMIT 50000];
                if(currentCase!=NULL)
                {
                    System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial5');
                    localSubCategory='Adherence Support Program';
                    localReason=currentCase.PSP_CORE_Adherence_Outcome__c;
                    localProgramid=currentCase.PSP_CORE_Program_ID__c;
                   
                
                
                }
                if(currentCase.PSP_CORE_Program_Affiliation__r.PSP_CORE_Program_Status__c!=system.label.PSP_CORE_Inactive)
                {
                   
                    System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial5.6'+currentCase.Tasks.Size()+''+currentCase.Tasks);
                    if(currentCase.Tasks.Size()==0)
                    {
                        System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial5.7');
                        Set<string> restartStrings=new Set<string>();
                        List<PSP_Case_Restart_Execute_Flows__c>  restartExecuteFlow=new List<PSP_Case_Restart_Execute_Flows__c>();
                        restartExecuteFlow=PSP_Case_Restart_Execute_Flows__c.getALL().values();
                        
                       System.debug('Restart flows123'+restartExecuteFlow);
                        if(restartExecuteFlow!=NULL)
                        {
                            System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial6');
                            for(PSP_Case_Restart_Execute_Flows__c  Restartflows:restartExecuteFlow)
                            {
                               
                                if(Restartflows.PSP_Workflow_Execution__c==system.label.PSP_CORE_Restart)
                                {       
                                    
                                    RestartStrings.add(Restartflows.Name);
                                }

                            
                            }

                        }
         
                        system.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial'+RestartStrings);
                         List<PSP_CORE_WorkFlow_Switch__c>  coreSwitchRecord=[select id,PSP_CORE_Program__c,PSP_CORE_Next_Flow__c,PSP_CORE_Next_Flow__R.Name from  PSP_CORE_WorkFlow_Switch__c where 
                                                                        PSP_CORE_Sub_Category__c=:localSubCategory and 
                                                                        PSP_CORE_Reason__c=:currentCase.PSP_CORE_Adherence_Outcome__c  and  
                                                                       
                                                                        PSP_CORE_Program__c=:localProgramid Limit 100];
                        if(coreSwitchRecord!=null  && coreSwitchRecord.size()>0 )
                        {
                           for(PSP_CORE_WorkFlow_Switch__c cwf:coreSwitchRecord) 
                           {
                                  System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial10'+ cwf.PSP_CORE_Next_Flow__R.Name); 
                                  System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial11'+ RestartStrings); 
                                if(RestartStrings.contains(cwf.PSP_CORE_Next_Flow__R.Name ))
                                {
                                    System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial12'+ localWorkflowID);
                                    localWorkflowID=cwf.PSP_CORE_Next_Flow__c;
                                    localWorkflowName=cwf.PSP_CORE_Next_Flow__R.Name;
                                    System.debug('<<<<<<<<<<<<<<<<<<<<<<<<Resintial3'+ localWorkflowID);
                                    
                                    
                                   // ClanceWorkflow(currentCase);
                                    
                                    
                                    
                               
                                currentCase.PSP_CORE_ReInvoke__c=false;
                               
                    
                                Set<string> setStaus= new set<String>{system.label.PSP_CORE_Adverse_Event_Assigned_Status,system.label.PSP_CORE_Not_Assigned,system.label.PSP_CORE_InProgress};
                                 List<Task> lstTask  = new List<Task>();
                                 /*
                                List<Task> lstTask =[Select id,Status from Task where WhatId=: currentCase.Id and Status in : setStaus LIMIT 50000];
                                for (Task ObjTask : lstTask){
                                    objTask.Status=system.label.PSP_CORE_Cancelled;
                                    objtask.APS_Skip_Validations__c = true;
                                    
                                }*/
                                
                                List<APS_Case_Workflow_Step__c> lstCWFS=[select Id, APS_Status__c,APS_Related_Object_SFDC_ID__c from APS_Case_Workflow_Step__c where APS_Related_Case__c=: currentCase.Id and APS_Status__c in : setStaus LIMIT 50000];
                                for (APS_Case_Workflow_Step__c objCWFS: lstCWFS){
                                    objCWFS.APS_Status__c=  system.label.PSP_CORE_Cancelled;
                                      if(objCWFS.APS_Related_Object_SFDC_ID__c!=null){
                                        Task ObjTask = new Task(Id=objCWFS.APS_Related_Object_SFDC_ID__c);
                                        objTask.Status=system.label.PSP_CORE_Cancelled;
                                        objtask.APS_Skip_Validations__c = true;
                                        lstTask.add(objtask);
                                    }
                                    
                                }
                               /****start of Update for defect 905*********/   
                               APS_PreventRecursion_Helper.PreventProgramWorkflowRecusive=false;
                               APS_PreventRecursion_Helper.PreventCaseWorkflowsRecusive=false;
                               APS_PreventRecursion_Helper.PreventTreatWorkflowsRecusive=false; 
                               system.debug('made false from from apsnew'); 
                               /****End of defect 905 modification*********/ 
                                if(!lstTask.IsEmpty()){
                                    Database.update(lstTask, false);
                                }
                                if(!lstCWFS.IsEmpty()){
                                    Database.update(lstCWFS, false);
                                }
                                    
                                    UpdatingCurrentWorkflowIdInCase(currentCase.Id,localWorkflowName, localWorkflowID);
                                    PSP_CORE_Workflow_Switch_Helper objWSH = new PSP_CORE_Workflow_Switch_Helper();
                                    objWSH.switchWorkflowStepsToCases(currentCase.Id,localWorkflowID);
                                    system.debug(' ');
                                   APS_PreventRecursion_Helper.ISCaseReasonWorkFlowSwitch=false;
                                    
                               }     
                            }
                        }
                    }
                }   
            }
        }Catch(Exception e)
        {
            system.debug('Show Error'+e.getMessage());
        }
        
        
        
    }
}