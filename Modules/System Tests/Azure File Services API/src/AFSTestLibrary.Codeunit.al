// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132515 "AFS Test Library"
{
    Access = Internal;

    var
        AzureTestLibrary: Codeunit "Azure Test Library";

    procedure GetDefaultAccountSAS(): Interface "Storage Service Authorization"
    begin
        exit(GetDefaultAccountSAS(AzureTestLibrary.GetAccessKey()));
    end;

    procedure GetDefaultAccountSAS(AccountKey: Text): Interface "Storage Service Authorization"
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
    begin
        exit(GetDefaultAccountSAS(AccountKey, StorageServiceAuthorization.GetDefaultAPIVersion()));
    end;

    procedure GetDefaultAccountSAS(AccountKey: Text; APIVersion: Enum "Storage Service API Version"): Interface "Storage Service Authorization"
    var
        StorageServiceAuthorization: Codeunit "Storage Service Authorization";
        SignedServices: List of [Enum "SAS Service Type"];
        SignedPermissions: List of [Enum "SAS Permission"];
        SignedResources: List of [Enum "SAS Resource Type"];
        SignedExpiry: DateTime;
        Second: Integer;
    begin
        Second := 1000;
        SignedExpiry := CurrentDateTime() + (60 * Second);

        SignedServices.Add(Enum::"SAS Service Type"::File);
        SignedPermissions.AddRange(Enum::"SAS Permission"::Create, Enum::"SAS Permission"::Write,
            Enum::"SAS Permission"::Delete, Enum::"SAS Permission"::List, Enum::"SAS Permission"::Read
        );
        SignedResources.AddRange(Enum::"SAS Resource Type"::Object, Enum::"SAS Resource Type"::Container);

        exit(StorageServiceAuthorization.CreateAccountSAS(
            AccountKey,
            APIVersion,
            SignedServices,
            SignedResources,
            SignedPermissions,
            SignedExpiry
        ));
    end;
}