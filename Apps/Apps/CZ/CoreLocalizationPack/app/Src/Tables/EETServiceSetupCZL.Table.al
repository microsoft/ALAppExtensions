// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Privacy;
using System.Security.Encryption;
using System.Threading;
using System.Utilities;

table 31125 "EET Service Setup CZL"
{
    Caption = 'EET Service Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "Service URL"; Text[250])
        {
            Caption = 'Service URL';
            ExtendedDatatype = URL;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EETServiceMgtCZL: Codeunit "EET Service Management CZL";
                Confirmed: Boolean;
                ProductionEnvironmentQst: Label 'There are still unprocessed EET Entries.\Entering the URL of the production environment, these entries will be registered in a production environment!\\ Do you want to continue?';
                NonproductionEnvironmentQst: Label 'There are still unprocessed EET Entries.\Entering the URL of the non-production environment, these entries will be registered in a non-production environment!\\ Do you want to continue?';
            begin
                Confirmed := true;
                if "Service URL" <> xRec."Service URL" then
                    if AreEETEntriesToSending() then
                        case "Service URL" of
                            EETServiceMgtCZL.GetWebServiceURLTxt():
                                Confirmed := ConfirmManagement.GetResponse(ProductionEnvironmentQst, false);
                            EETServiceMgtCZL.GetWebServicePlayGroundURLTxt():
                                Confirmed := ConfirmManagement.GetResponse(NonproductionEnvironmentQst, false);
                        end;

                if not Confirmed then
                    "Service URL" := xRec."Service URL";
            end;
        }
        field(10; "Sales Regime"; Enum "EET Sales Regime CZL")
        {
            Caption = 'Sales Regime';
            DataClassification = CustomerContent;
        }
        field(11; "Limit Response Time"; Integer)
        {
            Caption = 'Limit Response Time';
            DataClassification = CustomerContent;
            InitValue = 2000;
            MinValue = 2000;
        }
        field(12; "Appointing VAT Reg. No."; Text[20])
        {
            Caption = 'Appointing VAT Reg. No.';
            DataClassification = CustomerContent;
        }
        field(15; Enabled; Boolean)
        {

            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                JobQEntryCreatedQst: Label 'Job queue entry for sending electronic sales records has been created.\\Do you want to open the Job Queue Entries window?';
            begin
                if Enabled then begin
                    if not CustomerConsentMgt.ConfirmUserConsent() then begin
                        Enabled := false;
                        exit;
                    end;
                    ScheduleJobQueueEntry();
                    if ConfirmManagement.GetResponse(JobQEntryCreatedQst, false) then
                        ShowJobQueueEntry();
                end else
                    CancelJobQueueEntry();
            end;
        }
        field(17; "Certificate Code"; Code[10])
        {
            Caption = 'Certificate Code';
            TableRelation = "Certificate Code CZL";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        TestField("Primary Key", '');
        SetURLToDefault(false);
    end;

    var
        ConfirmManagement: Codeunit "Confirm Management";

    procedure SetURLToDefault(ShowDialog: Boolean)
    var
        EETServiceManagementCZL: Codeunit "EET Service Management CZL";
        Selection: Integer;
        URLOptionsQst: Label '&Production environment URL,&Non-production environment URL';
    begin
        TestField(Enabled, false);

        if not ShowDialog then begin
            EETServiceManagementCZL.SetURLToDefault(Rec);
            exit;
        end;

        Selection := 2;
        if GuiAllowed() then
            Selection := StrMenu(URLOptionsQst, Selection);

        case Selection of
            1:
                Validate("Service URL", EETServiceManagementCZL.GetWebServiceURLTxt());
            2:
                Validate("Service URL", EETServiceManagementCZL.GetWebServicePlayGroundURLTxt());
            else
                exit;
        end;
    end;

    local procedure ScheduleJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        DummyRecId: RecordId;
    begin
        JobQueueEntry.ScheduleRecurrentJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit,
          Codeunit::"EET Send Entries To Serv. CZL", DummyRecId);
    end;

    local procedure CancelJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"EET Send Entries To Serv. CZL") then
            JobQueueEntry.Cancel();
    end;

    procedure ShowJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"EET Send Entries To Serv. CZL");
        if JobQueueEntry.FindFirst() then
            Page.Run(Page::"Job Queue Entries", JobQueueEntry);
    end;

    local procedure AreEETEntriesToSending(): Boolean
    var
        EETEntryCZL: Record "EET Entry CZL";
    begin
        EETEntryCZL.SetFilterToSending();
        exit(not EETEntryCZL.IsEmpty());
    end;
}

