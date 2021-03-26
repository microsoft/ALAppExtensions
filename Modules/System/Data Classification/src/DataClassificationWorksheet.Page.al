// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality that allows users to classify their data.
/// </summary>
page 1751 "Data Classification Worksheet"
{
    Caption = 'Data Classification Worksheet';
    Extensible = false;
    AccessByPermission = TableData "Data Sensitivity" = R;
    ApplicationArea = All;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Manage,View';
    RefreshOnActivate = true;
    SourceTable = "Data Sensitivity";
    SourceTableView = WHERE("Field Caption" = FILTER(<> ''));
    UsageCategory = Administration;
    AdditionalSearchTerms = 'GDPR,Data Privacy,Privacy,Personal Data';
    ContextSensitiveHelpPage = 'admin-classifying-data-sensitivity';
    Permissions = tabledata Company = r,
                  tabledata "Data Sensitivity" = rm,
                  tabledata Field = r,
                  tabledata User = r;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table No"; "Table No")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the number of the affected table.';
                }
                field("Field No"; "Field No")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the number of the affected field.';
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the display name of the affected table.';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Enabled = false;
                    Style = Standard;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the display name of the affected field.';
                }
                field("Field Type"; "Field Type")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Editable = false;
                    Enabled = false;
                    Style = Standard;
                    StyleExpr = TRUE;
                    ToolTip = 'Specifies the type of the affected field.';
                    Visible = false;
                }
                field("Data Sensitivity"; "Data Sensitivity")
                {
                    ApplicationArea = All;
                    OptionCaption = 'Unclassified,Sensitive,Personal,Company Confidential,Normal';
                    ToolTip = 'Specifies the sensitivity of the data. Sensitive: Information about a data subject''s racial or ethnic origin, political opinions, religious beliefs, involvement with trade unions, physical or mental health, sexuality, or details about criminal offenses. Personal: Information that can be used to identify a data subject, either directly or in combination with other data or information. Confidential: Business data that you use for accounting or other business purposes, and do not want to expose to other entities. For example, this might include ledger entries. Normal: General data that does not belong to any other categories. ';

                    trigger OnValidate()
                    begin
                        Validate("Last Modified By", UserSecurityId());
                        Validate("Last Modified", CurrentDateTime());
                        SetLastModifiedBy();
                    end;
                }
                field("Data Classification"; "Data Classification")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies the classification of the data. Open Help to lean more.';
                }
                field(LastModifiedBy; LastModifiedByUser)
                {
                    ApplicationArea = All;
                    Caption = 'Last Modified By';
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies who last changed the field.';
                }
                field("Last Modified"; "Last Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies when the field was last changed.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Edit)
            {
                Caption = 'Edit';
                action("Set Up Data Classifications")
                {
                    ApplicationArea = All;
                    Caption = 'Set Up Data Classifications';
                    Image = Setup;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Open the Data Classification Assisted Setup Guide.';

                    trigger OnAction()
                    begin
                        PAGE.Run(PAGE::"Data Classification Wizard");
                    end;
                }
                action("Find New Fields")
                {
                    ApplicationArea = All;
                    Caption = 'Find New Fields';
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Search for new fields and add them in the data classification worksheet.';

                    trigger OnAction()
                    var
                        DataClassificationMgt: Codeunit "Data Classification Mgt.";
                    begin
                        DataClassificationMgt.SyncAllFields();
                    end;
                }
                action("Set as Sensitive")
                {
                    ApplicationArea = All;
                    Caption = 'Set as Sensitive';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Set the data sensitivity of the selected fields to Sensitive.';

                    trigger OnAction()
                    begin
                        SetSensitivityToSelection("Data Sensitivity"::Sensitive);
                    end;
                }
                action("Set as Personal")
                {
                    ApplicationArea = All;
                    Caption = 'Set as Personal';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Set the data sensitivity of the selected fields to Personal.';

                    trigger OnAction()
                    begin
                        SetSensitivityToSelection("Data Sensitivity"::Personal);
                    end;
                }
                action("Set as Normal")
                {
                    ApplicationArea = All;
                    Caption = 'Set as Normal';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Set the data sensitivity of the selected fields to Normal.';

                    trigger OnAction()
                    begin
                        SetSensitivityToSelection("Data Sensitivity"::Normal);
                    end;
                }
                action("Set as Company Confidential")
                {
                    ApplicationArea = All;
                    Caption = 'Set as Company Confidential';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Set the data sensitivity of the selected fields to Company Confidential.';

                    trigger OnAction()
                    begin
                        SetSensitivityToSelection("Data Sensitivity"::"Company Confidential");
                    end;
                }
                action("Set as Unclassified")
                {
                    ApplicationArea = All;
                    Caption = 'Set as Unclassified';
                    Image = ApplyEntries;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Set the data sensitivity of the selected fields to Unclassified.';

                    trigger OnAction()
                    begin
                        SetSensitivityToSelection("Data Sensitivity"::Unclassified);
                    end;
                }
            }
            group(View)
            {
                Caption = 'View';
                action("View Similar Fields")
                {
                    ApplicationArea = All;
                    Caption = 'View Similar Fields';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'View the fields of the related records that have similar name with one of the fields selected.';

                    trigger OnAction()
                    var
                        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
                    begin
                        CurrPage.SetSelectionFilter(Rec);
                        if not FindSet() then
                            Error(NoRecordsErr);
                        DataClassificationMgtImpl.FindSimilarFieldsInRelatedTables(Rec);
                        CurrPage.Update();
                    end;
                }
                action("View Unclassified")
                {
                    ApplicationArea = All;
                    Caption = 'View Unclassified';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'View only unclassified fields.';

                    trigger OnAction()
                    begin
                        ViewDataWithSensitivity("Data Sensitivity"::Unclassified);
                    end;
                }
                action("View Sensitive")
                {
                    ApplicationArea = All;
                    Caption = 'View Sensitive';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View only fields classified as Sensitive.';

                    trigger OnAction()
                    begin
                        ViewDataWithSensitivity("Data Sensitivity"::Sensitive);
                    end;
                }
                action("View Personal")
                {
                    ApplicationArea = All;
                    Caption = 'View Personal';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View only fields classified as Personal.';

                    trigger OnAction()
                    begin
                        ViewDataWithSensitivity("Data Sensitivity"::Personal);
                    end;
                }
                action("View Normal")
                {
                    ApplicationArea = All;
                    Caption = 'View Normal';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View only fields classified as Normal.';

                    trigger OnAction()
                    begin
                        ViewDataWithSensitivity("Data Sensitivity"::Normal);
                    end;
                }
                action("View Company Confidential")
                {
                    ApplicationArea = All;
                    Caption = 'View Company Confidential';
                    Image = FilterLines;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View only fields classified as Company Confidential.';

                    trigger OnAction()
                    begin
                        ViewDataWithSensitivity("Data Sensitivity"::"Company Confidential");
                    end;
                }
                action("View All")
                {
                    ApplicationArea = All;
                    Caption = 'View All';
                    Image = ClearFilter;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'View all fields.';

                    trigger OnAction()
                    begin
                        Reset();
                        SetRange("Company Name", CompanyName());
                        SetFilter("Field Caption", '<>%1', '');
                    end;
                }
                action("Show Field Content")
                {
                    ApplicationArea = All;
                    Caption = 'Show Field Content';
                    Enabled = FieldContentEnabled;
                    Image = "Table";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Show all the unique values of the selected field.';

                    trigger OnAction()
                    begin
                        ShowFieldContent();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        DataSensitivity: Record "Data Sensitivity";
        Field: Record Field;
    begin
        CurrPage.SetSelectionFilter(DataSensitivity);
        FieldContentEnabled := (("Field Type" = Field.Type::Code) or ("Field Type" = Field.Type::Text))
            and (DataSensitivity.Count() = 1);
    end;

    trigger OnAfterGetRecord()
    begin
        SetLastModifiedBy();
    end;

    trigger OnOpenPage()
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        SendLegalDisclaimerNotification();
        SetRange("Company Name", CompanyName());
        CreateEvalDataOrShowUnclassifiedDataIfTableIsEmpty();
        DataClassificationMgt.OnShowSyncFieldsNotification();
    end;

    var
        NoRecordsErr: Label 'No record has been selected.';
        FieldContentEnabled: Boolean;
        LastModifiedByUser: Text;
        DeletedUserTok: Label 'Deleted User';
        ClassifyAllfieldsQst: Label 'Do you want to set data sensitivity to %1 on %2 fields?', Comment = '%1=Choosen sensitivity %2=total number of fields';

    local procedure SetSensitivityToSelection(Sensitivity: Option)
    var
        DataSensitivity: Record "Data Sensitivity";
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        if ConfirmEditDataSensitivity(Sensitivity, DataSensitivity) then begin
            DataClassificationMgt.SetSensitivities(DataSensitivity, Sensitivity);
            CurrPage.Update();
        end;
    end;

    local procedure SetLastModifiedBy()
    var
        User: Record User;
    begin
        LastModifiedByUser := '';
        if User.Get("Last Modified By") then
            LastModifiedByUser := User."User Name"
        else
            if not IsNullGuid("Last Modified By") then
                LastModifiedByUser := DeletedUserTok;
    end;

    local procedure ConfirmEditDataSensitivity(Sensitivity: Option; var DataSensitivity: Record "Data Sensitivity"): Boolean
    var
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        CurrPage.SetSelectionFilter(DataSensitivity);
        if DataSensitivity.Count() > 20 then
            exit(Confirm(StrSubstNo(
                  ClassifyAllfieldsQst,
                  SelectStr(Sensitivity + 1, DataClassificationMgt.GetDataSensitivityOptionString()),
                  DataSensitivity.Count())));
        exit(true);
    end;

    local procedure SendLegalDisclaimerNotification()
    var
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
        Notification: Notification;
    begin
        Notification.Message := DataClassificationMgtImpl.GetLegalDisclaimerTxt();
        Notification.Send();
    end;

    local procedure CreateEvalDataOrShowUnclassifiedDataIfTableIsEmpty()
    var
        DataSensitivity: Record "Data Sensitivity";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        DataSensitivity.SetRange("Company Name", CompanyName());
        Company.Get(CompanyName());
        if DataSensitivity.IsEmpty() then
            if Company."Evaluation Company" then
                DataClassificationMgt.OnCreateEvaluationData()
            else
                DataClassificationMgt.PopulateDataSensitivityTable();
    end;

    local procedure ViewDataWithSensitivity(Sensitivity: Option)
    begin
        SetRange("Data Sensitivity", Sensitivity);
        CurrPage.Update();
    end;

    local procedure ShowFieldContent()
    var
        TempFieldContentBuffer: Record "Field Content Buffer" temporary;
        DataClassificationMgtImpl: Codeunit "Data Classification Mgt. Impl.";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.Open("Table No");
        if RecordRef.FindSet() then
            repeat
                FieldRef := RecordRef.Field("Field No");
                DataClassificationMgtImpl.PopulateFieldValue(FieldRef, TempFieldContentBuffer);
            until RecordRef.Next() = 0;
        PAGE.RunModal(PAGE::"Field Content Buffer", TempFieldContentBuffer);
    end;
}

