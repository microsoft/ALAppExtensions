codeunit 4701 "VAT Group Helper Functions"
{
    var
        AssistedSetupDescriptionTxt: Label 'VAT Group Management allows independent companies to enter into a VAT Group with the purpose of eliminating VAT claims amongst each other.';
        AssistedSetupTxt: Label 'Set up VAT Group Management';
        NoVATReportSetupErr: Label 'The VAT report setup was not found. You can create one on the VAT Report Setup page.';
        AssistedSetupHelpLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2141039', Locked = true;

    internal procedure SetOriginalRepresentativeAmount(VATReportHeader: Record "VAT Report Header")
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
        VATReportSetup: Record "VAT Report Setup";
    begin
        if not VATReportSetup.Get() then
            Error(NoVATReportSetupErr);

        if not (VATReportSetup."VAT Group Role" = VATReportSetup."VAT Group Role"::Representative) then
            exit;

        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        if VATStatementReportLine.FindSet(true, false) then
            repeat
                VATStatementReportLine."Representative Amount" := VATStatementReportLine.Amount;
                VATStatementReportLine.Modify();
            until VATStatementReportLine.Next() = 0;
    end;

    internal procedure CountApprovedMemberSubmissionsForPeriod(StartDate: Date; EndDate: Date): Integer
    var
        VATGroupApprovedMember: Record "VAT Group Approved Member";
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        Count: Integer;
    begin
        if VATGroupApprovedMember.FindSet() then begin
            VATGroupSubmissionHeader.SetCurrentKey("Start Date", "End Date");
            VATGroupSubmissionHeader.SetRange("Start Date", StartDate);
            VATGroupSubmissionHeader.SetRange("End Date", EndDate);
            VATGroupSubmissionHeader.SetRange("VAT Group Return No.", '');
            repeat
                VATGroupSubmissionHeader.SetRange("Group Member ID", VATGroupApprovedMember.ID);
                if not VATGroupSubmissionHeader.IsEmpty() then
                    Count += 1;
            until VATGroupApprovedMember.Next() = 0;
        end;

        exit(Count);
    end;

    internal procedure PrepareVATCalculation(VATReportHeader: Record "VAT Report Header"; VATStatementReportLine: Record "VAT Statement Report Line")
    var
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        VATGroupSubmissionLine: Record "VAT Group Submission Line";
        VATGroupApprovedMember: Record "VAT Group Approved Member";
        TempVATGroupCalculation: Record "VAT Group Calculation" temporary;
    begin
        if VATGroupApprovedMember.FindSet() then begin
            if VATReportHeader.Status > VATReportHeader.Status::Open then
                VATGroupSubmissionHeader.SetFiltersForLastSubmissionInAPeriod(
                    VATReportHeader."Start Date", VATReportHeader."End Date", true, VATReportHeader."No.")
            else
                VATGroupSubmissionHeader.SetFiltersForLastSubmissionInAPeriod(
                    VATReportHeader."Start Date", VATReportHeader."End Date", false, '');

            repeat
                VATGroupSubmissionHeader.SetRange("Group Member ID", VATGroupApprovedMember.ID);

                if VATGroupSubmissionHeader.FindLast() then begin
                    VATGroupSubmissionLine.SetRange("VAT Group Submission ID", VATGroupSubmissionHeader.ID);
                    VATGroupSubmissionLine.SetRange("Row No.", VATStatementReportLine."Row No.");

                    if VATGroupSubmissionLine.FindFirst() then begin
                        TempVATGroupCalculation.ID := CreateGuid();
                        TempVATGroupCalculation.Amount := VATGroupSubmissionLine.Amount;
                        TempVATGroupCalculation."Box No." := VATGroupSubmissionLine."Box No.";
                        TempVATGroupCalculation."Group Member Name" := VATGroupApprovedMember."Group Member Name";
                        TempVATGroupCalculation."VAT Group Submission No." := VATGroupSubmissionLine."VAT Group Submission No.";
                        TempVATGroupCalculation."VAT Group Submission ID" := VATGroupSubmissionHeader.ID;
                        TempVATGroupCalculation."VAT Report No." := VATReportHeader."No.";
                        TempVATGroupCalculation."Submitted On" := VATGroupSubmissionHeader."Submitted On";
                        TempVATGroupCalculation.Insert();
                    end;
                end;
            until VATGroupApprovedMember.Next() = 0;
        end;

        Page.Run(Page::"VAT Group Member Calculation", TempVATGroupCalculation);
    end;

    internal procedure MarkReleasedVATSubmissions(VATReportHeader: Record "VAT Report Header")
    var
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        VATGroupApprovedMember: Record "VAT Group Approved Member";
    begin
        if VATGroupApprovedMember.FindSet() then begin
            VATGroupSubmissionHeader.SetFiltersForLastSubmissionInAPeriod(VATReportHeader."Start Date", VATReportHeader."End Date", true, '');

            repeat
                VATGroupSubmissionHeader.SetRange("Group Member ID", VATGroupApprovedMember.ID);
                if VATGroupSubmissionHeader.FindLast() then begin
                    VATGroupSubmissionHeader."VAT Group Return No." := VATReportHeader."No.";
                    VATGroupSubmissionHeader.Modify();
                end;
            until VATGroupApprovedMember.Next() = 0;
        end;
    end;

    internal procedure MarkReopenedVATSubmissions(VATReportHeader: Record "VAT Report Header")
    var
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
    begin
        VATGroupSubmissionHeader.SetRange("VAT Group Return No.", VATReportHeader."No.");
        VATGroupSubmissionHeader.ModifyAll("VAT Group Return No.", '');
    end;

    internal procedure NewerVATSubmissionsExist(VATReportHeader: Record "VAT Report Header"): Boolean
    var
        VATGroupSubmissionHeader: Record "VAT Group Submission Header";
        NewerSubmissionFound: Boolean;
    begin
        VATGroupSubmissionHeader.SetRange("Start Date", VATReportHeader."Start Date");
        VATGroupSubmissionHeader.SetRange("End Date", VATReportHeader."End Date");
        VATGroupSubmissionHeader.SetRange("VAT Group Return No.", VATReportHeader."No.");
        if VATGroupSubmissionHeader.FindSet() then
            repeat
                NewerSubmissionFound := CheckForNewerSubmission(VATGroupSubmissionHeader);
            until VATGroupSubmissionHeader.Next() = 0;

        exit(NewerSubmissionFound);
    end;

    local procedure CheckForNewerSubmission(VATGroupSubmissionHeader: Record "VAT Group Submission Header"): Boolean
    var
        VATGroupSubmissionHeader2: Record "VAT Group Submission Header";
    begin
        VATGroupSubmissionHeader2.SetCurrentKey("Submitted On");
        VATGroupSubmissionHeader2.SetRange("Start Date", VATGroupSubmissionHeader."Start Date");
        VATGroupSubmissionHeader2.SetRange("End Date", VATGroupSubmissionHeader."End Date");
        VATGroupSubmissionHeader2.SetRange(Company, VATGroupSubmissionHeader.Company);
        VATGroupSubmissionHeader2.SetRange("Group Member ID", VATGroupSubmissionHeader."Group Member ID");
        if VATGroupSubmissionHeader2.FindLast() then
            exit(VATGroupSubmissionHeader2."Submitted On" > VATGroupSubmissionHeader."Submitted On");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure AddVATReportSetupWizard()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.InsertAssistedSetup(AssistedSetupTxt, AssistedSetupTxt, AssistedSetupDescriptionTxt, 0, ObjectType::Page, Page::"VAT Group Setup Guide", "Assisted Setup Group"::GettingStarted, '', "Video Category"::Uncategorized, AssistedSetupHelpLinkTxt);
    end;

    internal procedure GetVATGroupDefaultBCVersion(): Enum "VAT Group BC Version"
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        exit(VATReportSetup."VAT Group BC Version"::BC);
    end;
}