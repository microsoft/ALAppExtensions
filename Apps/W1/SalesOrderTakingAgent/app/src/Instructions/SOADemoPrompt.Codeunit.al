namespace Agent.SalesOrderTaker.Instructions;

codeunit 4306 "SOA Demo Prompt"
{
    trigger OnRun()
    begin
        CreateFullSalesOrderTakerSetup();
    end;

    var
        SOAInstructionTemplate: Record "SOA Instruction Template";
        SOAInstructionPhase: Record "SOA Instruction Phase";
        SOAInstructionTaskPolicy: Record "SOA Instruction Task/Policy";
        SOAInstructionPhaseStep: Record "SOA Instruction Phase Step";
        SOAInstructionPrompt: Record "SOA Instruction Prompt";
        SOAInstructionsMgt: Codeunit "SOA Instructions Mgt.";
        TemplateLbl: Label 'SALES ORDER TAKER';
        TemplateDescLbl: Label 'Sales order taking agent';
        TaskPromptLbl: Label 'TASK';
        TaskPromptTextLbl: Label '**Task**%1You are acting as a sales order taker in the sales department running on Business Central. You are responsible for handling incoming sales quote requests via email. Follow these detailed steps to process a sales quote request and convert it to a sales order upon approval:%1<<PHASE 1>>%1<<PHASE 2>>%1<<PHASE 3>>%1<<PHASE 4>>%1<<PHASE 5>>%1Make sure to follow the steps meticulously to ensure accuracy and efficiency in creating and processing sales quotes in Business Central.%1', Comment = '%1: NewLine';
        Prompt11Lbl: Label '1-1 RECEIVE EMAIL';
        Prompt11TextLbl: Label '**Email Reception:**%1- Monitor the shared inbox for incoming emails.%1- Identify emails requesting a sales quote by analyzing the content. Look for specific mentions of products, desired quantities, dates, and any additional information.%1', Comment = '%1: NewLine';
        Prompt12Lbl: Label '1-2 ANALYZE EXTRACT';
        Prompt12TextLbl: Label '**Analyze and Extract Information:**%1- Extract the product names, quantities, units of measure, requested delivery dates, and any other pertinent information from the email.%1- Ensure that both the product name and quantity are present, as they are essential for creating the sales quote. If either is missing, then request assistance.%1', Comment = '%1: NewLine';
        Prompt13Lbl: Label '1-3 FIND CONTACT';
        Prompt13TextLbl: Label '**Find Contact or Customer in Business Central:**%1- First, search for the Contact in Business Central. Use details from the email message, such as the sender''s name, email address, company name, phone number.%1', Comment = '%1: NewLine';
        Prompt14Lbl: Label '1-4 FIND CUSTOMER';
        Prompt14TextLbl: Label '- If the contact is not found, search for the Customer instead.%1- If neither Contact nor Customer is found, then request assistance.%1', Comment = '%1: NewLine';
        Prompt15Lbl: Label '1-5 VERIFY PARTNER';
        Prompt15TextLbl: Label '- Verify the credit limit for the contact or customer and ensure that all posting fields are correctly filled.%1', Comment = '%1: NewLine';
        Prompt21Lbl: Label '2-1 CREATE QUOTE';
        Prompt21TextLbl: Label '**Create Sales Quote:**%1- Based on the Contact or Customer found, navigate to their card and select "Sales Quote" action in "New Document" group to initiate a new sales quote.%1- A new sales quote form will open, pre-filled with the contact or customer''s information.%1', Comment = '%1: NewLine';
        Prompt31Lbl: Label '3-1 ADD DETAILS';
        Prompt31TextLbl: Label '**Populate Sales Quote Details:**%1', Comment = '%1: NewLine';
        Prompt32Lbl: Label '3-2 ADD DATE';
        Prompt32TextLbl: Label '- If the email specifies a "Requested Delivery Date," populate this field accordingly.%1', Comment = '%1: NewLine';
        Prompt33Lbl: Label '3-3 VERIFY CUST NO';
        Prompt33TextLbl: Label '- Verify that Customer No. and Customer Name are filled in on the sales quote form.%1', Comment = '%1: NewLine';
        Prompt34Lbl: Label '3-4 VERIFY ADDRESS';
        Prompt34TextLbl: Label '- Ensure that address fields are filled in.%1', Comment = '%1: NewLine';
        Prompt35Lbl: Label '3-5 ADD LINES';
        Prompt35TextLbl: Label '- Add sales quote lines:%1  - Set the line type to "Item."%1  - Populate the "No.", "Variant Code", "Quantity", and "Unit of Measure Code" fields with the information extracted from the email.%1- Business Central will automatically calculate prices and taxes.%1', Comment = '%1: NewLine';
        Prompt41Lbl: Label '4-1 SEND REPLY';
        Prompt41TextLbl: Label '**Send Sales Quote to Customer:**%1- Convert the newly created sales quote to a PDF document.%1- Reply to the original email with the following text: "We sent you a quote, check your email titled "Quote XXXX" and confirm if you want to proceed."%1- Attach the PDF document to this email.%1%1**Example Email Template**%1Subject: Sales Quote XXXX%1Body:%1Dear [Customer Name],%1Thank you for your request. We have generated a sales quote based on the details provided. Please find the attached PDF document titled "Quote XXXX".%1Kindly review the quote and confirm if you wish to proceed with the order.%1Best regards,%1[Your Company Name]%1', Comment = '%1: NewLine';
        Prompt51Lbl: Label '5-1 QUOTE TO ORDER';
        Prompt51TextLbl: Label '**Convert Quote to Sales Order:**%1- Once the customer approves the quote, select "Make Order" to convert the sales quote into a sales order in Business Central.%1', Comment = '%1: NewLine';
        Task11Lbl: Label 'Monitor and read emails';
        Task12Lbl: Label 'Extract data from email';
        Task13Lbl: Label 'Find contact';
        Policy14Lbl: Label 'Contact not found, find customer';
        Policy15Lbl: Label 'Verify found contact or customer';
        Task21Lbl: Label 'Create sales quote';
        Task31Lbl: Label 'Populate sales quote details';
        Policy32Lbl: Label 'Add requested delivery date';
        Policy33Lbl: Label 'Verify customer number and name';
        Policy34Lbl: Label 'Verify address';
        Task35Lbl: Label 'Add sales quote lines';
        Task41Lbl: Label 'Send sales quote to customer';
        Task51Lbl: Label 'Convert quote to sales order';

    procedure CreateFullSalesOrderTakerSetup()
    begin
        DeleteExistingSetup();

        CreatePrompts();
        CreateTasksAndPolicies();
        CreateTemplates();
        CreatePhases();
        CreatePhaseSteps();
    end;

    local procedure DeleteExistingSetup()
    begin
        SOAInstructionPrompt.Reset();
        SOAInstructionPrompt.DeleteAll();
        SOAInstructionTaskPolicy.Reset();
        SOAInstructionTaskPolicy.DeleteAll();
        SOAInstructionTemplate.Reset();
        SOAInstructionTemplate.DeleteAll();
        SOAInstructionPhase.Reset();
        SOAInstructionPhase.DeleteAll();
        SOAInstructionPhaseStep.Reset();
        SOAInstructionPhaseStep.DeleteAll();
    end;

    local procedure CreatePrompts()
    begin
        CreatePrompt(TaskPromptLbl, TaskPromptTextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt11Lbl, Prompt11TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt12Lbl, Prompt12TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt13Lbl, Prompt13TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt14Lbl, Prompt14TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt15Lbl, Prompt15TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt21Lbl, Prompt21TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt31Lbl, Prompt31TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt32Lbl, Prompt32TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt33Lbl, Prompt33TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt34Lbl, Prompt34TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt35Lbl, Prompt35TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt41Lbl, Prompt41TextLbl, "SOA Yes/No Toggle State"::Yes);
        CreatePrompt(Prompt51Lbl, Prompt51TextLbl, "SOA Yes/No Toggle State"::Yes);
    end;

    local procedure CreatePrompt(Name: Code[20]; PromptText: Text; Enabled: Enum "SOA Yes/No Toggle State")
    var
        NewLine: Text[2];
    begin
        SOAInstructionPrompt.Init();
        SOAInstructionPrompt.Code := Name;
        SOAInstructionPrompt.Enabled := Enabled;
        SOAInstructionPrompt.Insert();

        NewLine := '  ';
        NewLine[1] := 13;
        NewLine[2] := 10;

        SOAInstructionsMgt.SetPrompt(SOAInstructionPrompt, StrSubstNo(PromptText, NewLine));
        SOAInstructionPrompt.Modify();
    end;

    local procedure CreateTasksAndPolicies()
    begin
        CreateTaskAndPolicy(1, "SOA Phase Step Type"::Task, Task11Lbl, Prompt11Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(2, "SOA Phase Step Type"::Task, Task12Lbl, Prompt12Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(3, "SOA Phase Step Type"::Task, Task13Lbl, Prompt13Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(4, "SOA Phase Step Type"::Policy, Policy14Lbl, Prompt14Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(5, "SOA Phase Step Type"::Policy, Policy15Lbl, Prompt15Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(6, "SOA Phase Step Type"::Task, Task21Lbl, Prompt21Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(7, "SOA Phase Step Type"::Task, Task31Lbl, Prompt31Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(8, "SOA Phase Step Type"::Policy, Policy32Lbl, Prompt32Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(9, "SOA Phase Step Type"::Policy, Policy33Lbl, Prompt33Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(10, "SOA Phase Step Type"::Policy, Policy34Lbl, Prompt34Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(11, "SOA Phase Step Type"::Task, Task35Lbl, Prompt35Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(12, "SOA Phase Step Type"::Task, Task41Lbl, Prompt41Lbl, "SOA Yes/No Toggle State"::Yes);
        CreateTaskAndPolicy(13, "SOA Phase Step Type"::Task, Task51Lbl, Prompt51Lbl, "SOA Yes/No Toggle State"::Yes);
    end;

    local procedure CreateTaskAndPolicy(SortingOrderNo: Integer; Type: Enum "SOA Phase Step Type"; Name: Text; PromptCode: Code[20]; Enabled: Enum "SOA Yes/No Toggle State")
    begin
        SOAInstructionTaskPolicy.Init();
        SOAInstructionTaskPolicy."Sorting Order No." := SortingOrderNo;
        SOAInstructionTaskPolicy.Type := Type;
        SOAInstructionTaskPolicy.Name := CopyStr(Name, 1, MaxStrLen(SOAInstructionTaskPolicy.Name));
        SOAInstructionTaskPolicy."Prompt Code" := PromptCode;
        SOAInstructionTaskPolicy.Enabled := Enabled;
        SOAInstructionTaskPolicy.Insert();
    end;

    local procedure CreatePhases()
    begin
        CreatePhase(1, "SOA Phases"::"Identify Business Partner", "SOA Yes/No Toggle State"::Yes);
        CreatePhase(2, "SOA Phases"::"Create Sales Document", "SOA Yes/No Toggle State"::Yes);
        CreatePhase(3, "SOA Phases"::"Add Details to Sales Document", "SOA Yes/No Toggle State"::Yes);
        CreatePhase(4, "SOA Phases"::"Send Sales Document", "SOA Yes/No Toggle State"::Yes);
        CreatePhase(5, "SOA Phases"::"Process Response", "SOA Yes/No Toggle State"::Yes);
    end;

    local procedure CreatePhase(PhaseOrderNo: Integer; Phase: Enum "SOA Phases"; Enabled: Enum "SOA Yes/No Toggle State")
    begin
        SOAInstructionPhase.Init();
        SOAInstructionPhase."Template Name" := SOAInstructionTemplate.Name;
        SOAInstructionPhase.Phase := Phase;
        SOAInstructionPhase."Phase Order No." := PhaseOrderNo;
        SOAInstructionPhase.Enabled := Enabled;
        SOAInstructionPhase.Insert();
    end;

    local procedure CreatePhaseSteps()
    begin
        CreatePhaseStep("SOA Phases"::"Identify Business Partner", 1, "SOA Phase Step Type"::Task, Task11Lbl, 0, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Identify Business Partner", 2, "SOA Phase Step Type"::Task, Task12Lbl, 0, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Identify Business Partner", 3, "SOA Phase Step Type"::Task, Task13Lbl, 0, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Identify Business Partner", 4, "SOA Phase Step Type"::Policy, Policy14Lbl, 1, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Identify Business Partner", 5, "SOA Phase Step Type"::Policy, Policy15Lbl, 1, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Create Sales Document", 1, "SOA Phase Step Type"::Task, Task21Lbl, 0, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Add Details to Sales Document", 1, "SOA Phase Step Type"::Task, Task31Lbl, 0, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Add Details to Sales Document", 2, "SOA Phase Step Type"::Policy, Policy32Lbl, 1, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Add Details to Sales Document", 3, "SOA Phase Step Type"::Policy, Policy33Lbl, 1, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Add Details to Sales Document", 4, "SOA Phase Step Type"::Policy, Policy34Lbl, 1, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Add Details to Sales Document", 5, "SOA Phase Step Type"::Task, Task35Lbl, 0, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Send Sales Document", 1, "SOA Phase Step Type"::Task, Task41Lbl, 0, "SOA Yes/No Toggle State"::Yes);
        CreatePhaseStep("SOA Phases"::"Process Response", 1, "SOA Phase Step Type"::Task, Task51Lbl, 0, "SOA Yes/No Toggle State"::Yes);
    end;

    local procedure CreatePhaseStep(Phase: Enum "SOA Phases"; StepNo: Integer; StepType: Enum "SOA Phase Step Type"; StepName: Text; Indentation: Integer; Enabled: Enum "SOA Yes/No Toggle State")
    begin
        SOAInstructionPhaseStep.Init();
        SOAInstructionPhaseStep.Phase := Phase;
        SOAInstructionPhaseStep."Step No." := StepNo;
        SOAInstructionPhaseStep."Step Type" := StepType;
        SOAInstructionPhaseStep."Step Name" := CopyStr(StepName, 1, MaxStrLen(SOAInstructionPhaseStep."Step Name"));
        SOAInstructionPhaseStep.Indentation := Indentation;
        SOAInstructionPhaseStep.Enabled := Enabled;
        SOAInstructionPhaseStep.Insert();
    end;

    local procedure CreateTemplates()
    begin
        SOAInstructionTemplate.Init();
        SOAInstructionTemplate.Name := TemplateLbl;
        SOAInstructionTemplate.Description := TemplateDescLbl;
        SOAInstructionTemplate.Enabled := "SOA Yes/No Toggle State"::Yes;
        SOAInstructionTemplate."Prompt Code" := TaskPromptLbl;
        SOAInstructionTemplate.Insert();
    end;
}