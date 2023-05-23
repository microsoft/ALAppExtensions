// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3918 "Record Reference Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure Initialize(RecordRef: RecordRef; var RecordReference: Interface "Record Reference"; CallerModule: ModuleInfo)
    var
        RecordReferenceFacade: Codeunit "Record Reference";
        RecordReferenceDefaultImpl: Codeunit "Record Reference Default Impl.";
        IsInitialized: Boolean;
    begin
        RecordReferenceFacade.OnInitialize(RecordRef, RecordReference, CallerModule, IsInitialized);
        if IsInitialized then
            exit;

        RecordReference := RecordReferenceDefaultImpl;
        RecordReferenceDefaultImpl.SetInitializedCalledModuleId(CallerModule.Id);
    end;
}