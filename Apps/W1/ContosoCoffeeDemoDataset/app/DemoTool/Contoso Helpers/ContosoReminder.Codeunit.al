codeunit 5694 "Contoso Reminder"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Reminder Attachment Text" = ri,
                    tabledata "Reminder Email Text" = ri,
                    tabledata "Reminder Text" = rim,
                    tabledata "Reminder Level" = rim,
                    tabledata "Reminder Terms" = rim,
                    tabledata "Create Reminders Setup" = rim,
                    tabledata "Reminder Action" = rim,
                    tabledata "Reminder Action Group" = rim,
                    tabledata "Send Reminders Setup" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertReminderLevel(ReminderTermsCode: Code[10]; No: Integer; GracePeriod: Text; AdditionalFeeLCY: Decimal; DueDateCalculation: Text): Record "Reminder Level"
    var
        ReminderLevel: Record "Reminder Level";
        Exists: Boolean;
    begin
        if ReminderLevel.Get(ReminderTermsCode, No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ReminderLevel.Validate("Reminder Terms Code", ReminderTermsCode);
        ReminderLevel.Validate("No.", No);
        Evaluate(ReminderLevel."Grace Period", GracePeriod);
        ReminderLevel.Validate("Grace Period");
        ReminderLevel.Validate("Additional Fee (LCY)", AdditionalFeeLCY);
        Evaluate(ReminderLevel."Due Date Calculation", DueDateCalculation);
        ReminderLevel.Validate("Due Date Calculation");

        if Exists then
            ReminderLevel.Modify(true)
        else
            ReminderLevel.Insert(true);

        exit(ReminderLevel);
    end;

    procedure InsertReminderTerms(Code: Code[10]; Description: Text[100]): Record "Reminder Terms";
    var
        ReminderTerms: Record "Reminder Terms";
        Exists: Boolean;
    begin
        if ReminderTerms.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ReminderTerms.Validate(Code, Code);
        ReminderTerms.Description := Description;

        if Exists then
            ReminderTerms.Modify(true)
        else
            ReminderTerms.Insert(true);

        exit(ReminderTerms);
    end;

    procedure InsertCreateRemindersSetup(Code: Code[50]; ActionGroupCode: Code[50]; Description: Text[50])
    var
        CreateRemindersSetup: Record "Create Reminders Setup";
        Exists: Boolean;
    begin
        if CreateRemindersSetup.Get(Code, ActionGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CreateRemindersSetup.Validate(Code, Code);
        CreateRemindersSetup.Validate("Action Group Code", ActionGroupCode);
        CreateRemindersSetup.Validate(Description, Description);

        if Exists then
            CreateRemindersSetup.Modify(true)
        else
            CreateRemindersSetup.Insert(true);
    end;

    procedure InsertReminderAction(ReminderActionGroupCode: Code[50]; Code: Code[50]; Type: Enum "Reminder Action")
    var
        ReminderAction: Record "Reminder Action";
        Exists: Boolean;
    begin
        if ReminderAction.Get(ReminderActionGroupCode, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ReminderAction.Validate("Reminder Action Group Code", ReminderActionGroupCode);
        ReminderAction.Validate(Code, Code);
        ReminderAction.Validate(Type, Type);

        if Exists then
            ReminderAction.Modify(true)
        else
            ReminderAction.Insert(true);
    end;

    procedure InsertReminderActionGroup(Code: Code[50]; Description: Text[100])
    var
        ReminderActionGroup: Record "Reminder Action Group";
        Exists: Boolean;
    begin
        if ReminderActionGroup.Get(Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ReminderActionGroup.Validate(Code, Code);
        ReminderActionGroup.Validate(Description, Description);

        if Exists then
            ReminderActionGroup.Modify(true)
        else
            ReminderActionGroup.Insert(true);
    end;

    procedure InsertSendRemindersSetup(Code: Code[50]; ActionGroupCode: Code[50]; Description: Text[50]; SendbyEmail: Boolean; LogInteraction: Boolean; AttachInvoiceDocuments: Integer)
    var
        SendRemindersSetup: Record "Send Reminders Setup";
        Exists: Boolean;
    begin
        if SendRemindersSetup.Get(Code, ActionGroupCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        SendRemindersSetup.Validate(Code, Code);
        SendRemindersSetup.Validate("Action Group Code", ActionGroupCode);
        SendRemindersSetup.Validate(Description, Description);
        SendRemindersSetup.Validate("Send by Email", SendbyEmail);
        SendRemindersSetup.Validate("Log Interaction", LogInteraction);
        SendRemindersSetup.Validate("Attach Invoice Documents", AttachInvoiceDocuments);

        if Exists then
            SendRemindersSetup.Modify(true)
        else
            SendRemindersSetup.Insert(true);
    end;

    procedure InsertReminderEmailText(ReminderTermsCode: Code[10]; ReminderLevelNo: Integer; LanguageCode: Code[10]; SourceType: Enum "Reminder Text Source Type"; Subject: Text[128]; Greeting: Text[128]; BodyText: Text; Closing: Text[128]): Record "Reminder Email Text"
    var
        ReminderEmailText: Record "Reminder Email Text";
        ReminderLevel: Record "Reminder Level";
        ReminderTerms: Record "Reminder Terms";
    begin
        ReminderEmailText.Validate(ID, CreateGuid());
        ReminderEmailText.Validate("Language Code", LanguageCode);
        ReminderEmailText.Validate("Source Type", SourceType);
        ReminderEmailText.Validate(Subject, Subject);
        ReminderEmailText.Validate(Greeting, Greeting);
        ReminderEmailText.Validate(Closing, Closing);
        ReminderEmailText.Insert(true);

        case SourceType of
            SourceType::"Reminder Level":
                begin
                    ReminderLevel.Get(ReminderTermsCode, ReminderLevelNo);
                    if IsNullGuid(ReminderLevel."Reminder Email Text") then begin
                        ReminderLevel.Validate("Reminder Email Text", ReminderEmailText.ID);
                        ReminderLevel.Modify(true);
                    end;
                end;
            SourceType::"Reminder Term":
                begin
                    ReminderTerms.Get(ReminderTermsCode);
                    if IsNullGuid(ReminderTerms."Reminder Email Text") then begin
                        ReminderTerms.Validate("Reminder Email Text", ReminderEmailText.ID);
                        ReminderTerms.Modify(true);
                    end;
                end;
        end;
        exit(ReminderEmailText);
    end;

    procedure InsertReminderAttachText(ReminderGuid: Guid; ReminderTermsCode: Code[10]; ReminderLevelNo: Integer; LanguageCode: Code[10]; SourceType: Enum "Reminder Text Source Type"; FileName: Text[100]; BeginningLine: Text[100]; InlineFeeDescription: Text[100]; EndingLine: Text[100])
    var
        ReminderAttachmentText: Record "Reminder Attachment Text";
        ReminderLevel: Record "Reminder Level";
        ReminderTerms: Record "Reminder Terms";
    begin
        ReminderAttachmentText.Validate(Id, ReminderGuid);
        ReminderAttachmentText.Validate("Language Code", LanguageCode);
        ReminderAttachmentText.Validate("Source Type", SourceType);
        ReminderAttachmentText.Validate("File Name", FileName);
        ReminderAttachmentText.Validate("Inline Fee Description", InlineFeeDescription);
        ReminderAttachmentText.Insert(true);

        case SourceType of
            SourceType::"Reminder Level":
                begin
                    ReminderLevel.Get(ReminderTermsCode, ReminderLevelNo);
                    if IsNullGuid(ReminderLevel."Reminder Attachment Text") then begin
                        ReminderLevel.Validate("Reminder Attachment Text", ReminderAttachmentText.Id);
                        ReminderLevel.Modify(true);
                    end;
                end;
            SourceType::"Reminder Term":
                begin
                    ReminderTerms.Get(ReminderTermsCode);
                    if IsNullGuid(ReminderTerms."Reminder Attachment Text") then begin
                        ReminderTerms.Validate("Reminder Attachment Text", ReminderAttachmentText.Id);
                        ReminderTerms.Modify(true);
                    end;
                end;
        end;
    end;

    procedure InsertReminderText(ReminderTermsCode: Code[10]; ReminderLevel: Integer; Position: Enum "Reminder Text Position"; LineNo: Integer; Text: Text[100])
    var
        ReminderText: Record "Reminder Text";
        Exists: Boolean;
    begin
        if ReminderText.Get(ReminderTermsCode, ReminderLevel, Position, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ReminderText.Validate("Reminder Terms Code", ReminderTermsCode);
        ReminderText.Validate("Reminder Level", ReminderLevel);
        ReminderText.Validate(Position, Position);
        ReminderText.Validate("Line No.", LineNo);
        ReminderText.Validate(Text, Text);

        if Exists then
            ReminderText.Modify(true)
        else
            ReminderText.Insert(true);
    end;
}