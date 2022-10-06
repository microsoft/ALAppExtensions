// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays the deployment status for extensions that are deployed or are scheduled for deployment.
/// </summary>
page 2505 "Extn. Installation Progress"
{
    PageType = NavigatePage;
    Caption = 'Installing app';

    layout
    {
        area(Content)
        {
            group(Main)
            {
                ShowCaption = false;
                Visible = FirstPageVisible;
                group(Instruction)
                {
                    ShowCaption = false;
                    InstructionalText = 'Installation might take a minute. You can work on other tasks while you wait and check the status later on the Extension Installation Status page.';

                    usercontrol(WaitSpinner; WaitSpinner)
                    {
                        ApplicationArea = All;

                        trigger Ready()
                        begin
                            if Initialized then
                                exit;
                            Initialized := true;

                            CurrPage.WaitSpinner.Wait(20);
                        end;

                        trigger Callback()
                        begin
                            if NeedToWait() then
                                CurrPage.WaitSpinner.Wait(5)
                            else
                                CurrPage.Close();
                        end;
                    }
                }
            }
        }
    }

    var
        Initialized: Boolean;
        FirstPageVisible: Boolean;
        OperationIdToMonitor: Guid;
        InvalidOperationIdErr: Label 'Invalid operation id.';
        InstallationInProgressTxt: Label 'User has chosen to close the installation progress and is not waiting for the installation to finish.';

    trigger OnOpenPage()
    begin
        FirstPageVisible := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NavAppTenantOperation: Record "NAV App Tenant Operation";
        ExtensionOperationImpl: Codeunit "Extension Operation Impl";
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
            ExtensionOperationImpl.RefreshStatus(OperationIdToMonitor);
            if NavAppTenantOperation.Get(OperationIdToMonitor) then
                if NavAppTenantOperation.Status = NavAppTenantOperation.Status::InProgress then
                    Session.LogMessage('0000I2P', InstallationInProgressTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'Extensions');
        end;
    end;

    internal procedure SetOperationIdToMonitor(OperationId: Guid)
    begin
        OperationIdToMonitor := OperationId;
    end;

    local procedure NeedToWait(): Boolean
    var
        NavAppTenantOperation: Record "NAV App Tenant Operation";
        ExtensionOperationImpl: Codeunit "Extension Operation Impl";
    begin
        ExtensionOperationImpl.RefreshStatus(OperationIdToMonitor);
        if not NavAppTenantOperation.Get(OperationIdToMonitor) then
            Error(InvalidOperationIdErr);

        if NavAppTenantOperation.Status = NavAppTenantOperation.Status::InProgress then
            exit(true);
    end;
}


