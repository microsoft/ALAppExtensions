// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Azure.Identity;

codeunit 6383 SignUpErrorSensitive
{
    Access = Internal;
    Description = 'Create functions to run sensitive code that may fail out of your control but you need to keep the code going';

    trigger OnRun()
    begin
        case gParameter of
            'AADDETAILS':
                TryGetAADDetails();
        end;
    end;

    //
    // Error prone function(s)
    //
    local procedure TryGetAADDetails()
    begin
        gResult1 := AzureADTenant.GetAadTenantId();
        gResult2 := AzureADTenant.GetAadTenantDomainName();
    end;

    //
    // Generic Get/Set methods to communicate before and after try-catch
    //
    procedure SetParameter(Parameter: Text)
    begin
        gParameter := Parameter;
    end;

    procedure GetFirstResult(): Text;
    begin
        exit(gResult1);
    end;

    procedure GetSecondResult(): Text;
    begin
        exit(gResult2);
    end;

    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        gParameter: Text;
        gResult1: Text;
        gResult2: Text;
}