// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Environment.Configuration;

/// <summary>
/// API Page that enables a user to manage available features.
/// </summary>
page 30092 "APIV2 - Feature Management"
{
    PageType = API;
    Caption = 'feature', Locked = true;
    EntityCaption = 'Feature';
    EntitySetCaption = 'Features';
    APIPublisher = 'microsoft';
    APIGroup = 'automation';
    APIVersion = 'v2.0';
    EntityName = 'feature';
    EntitySetName = 'features';
    SourceTable = "Feature Key";
    DelayedInsert = true;
    ODataKeyFields = ID;
    Editable = false;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata "Feature Data Update Status" = r,
                  tabledata "Feature Key" = rm;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.ID)
                {
                    Caption = 'ID';
                }
                field(enabled; Rec.Enabled)
                {
                    Caption = 'Enabled';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(learnMoreLink; Rec."Learn More Link")
                {
                    Caption = 'Documentation link';
                }
                field(mandatoryBy; Rec."Mandatory By")
                {
                    Caption = 'Mandatory By';
                }
                field(canTry; Rec."Can Try")
                {
                    Caption = 'Can Try';
                }
                field(isOneWay; Rec."Is One Way")
                {
                    Caption = 'Is One Way';
                }
                field(dataUpdateRequired; Rec."Data Update Required")
                {
                    Caption = 'Data Update Required';
                }
                field(mandatoryByVersion; Rec."Mandatory By Version")
                {
                    Caption = 'Mandatory By Version';
                }
                field(descriptionInEnglish; Rec."Description In English")
                {
                    Caption = 'Description In English';
                }
            }
        }
    }

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Activate(var ActionContext: WebServiceActionContext; UpdateInBackground: Boolean; StartDateTime: DateTime)
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
    begin
        if Rec.Enabled = Rec.Enabled::"All Users" then
            Error(AlreadyEnabledErr);

        if UpdateInBackground and Rec."Data Update Required" then
            if not TaskScheduler.CanCreateTask() then
                Error(CantScheduleTaskErr);

        Rec.Enabled := Rec.Enabled::"All Users";
        Rec.Modify(true);

        // Update data if needed
        FeatureManagementFacade.GetFeatureDataUpdateStatus(Rec, FeatureDataUpdateStatus);

        if FeatureDataUpdateStatus."Data Update Required" then begin
            FeatureDataUpdateStatus."Background Task" := UpdateInBackground;
            FeatureDataUpdateStatus."Start Date/Time" := CurrentDateTime();
            FeatureDataUpdateStatus.Confirmed := true;
            FeatureDataUpdateStatus.Modify(true);
            FeatureManagementFacade.UpdateSilently(FeatureDataUpdateStatus);
        end;

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Feature Management");
        ActionContext.AddEntityKey(Rec.FieldNo(ID), Rec.ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure Deactivate(var ActionContext: WebServiceActionContext)
    begin
        if Rec.Enabled = Rec.Enabled::None then
            Error(AlreadyDisabledErr);

        if Rec."Is One Way" then
            Error(OneWayAlreadyEnabledErr);

        Rec.Enabled := Rec.Enabled::None;
        Rec.Modify(true);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Feature Management");
        ActionContext.AddEntityKey(Rec.FieldNo(ID), Rec.ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        OneWayAlreadyEnabledErr: Label 'This feature has already been enabled and cannot be disabled.';
        AlreadyEnabledErr: Label 'This feature has already been enabled';
        AlreadyDisabledErr: Label 'This feature has already been disabled.';
        CantScheduleTaskErr: Label 'Cannot create a background task. Please check your permissions or run it in the same session.';
}