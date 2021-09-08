// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132914 "Azure AD User Mgt Test Library"
{
    /// <summary>    
    /// Calls the Run function of the Azure AD User Mgmt. Impl. codeunit. This function exists purely 
    /// for test purposes.
    /// </summary>
    /// <param name="ForUserSecurityId">The user security ID that the function is run for.</param>
    procedure Run(ForUserSecurityId: Guid)
    var
        AzureADUserMgmtImpl: Codeunit "Azure AD User Mgmt. Impl.";
    begin
        AzureADUserMgmtImpl.SetTestInProgress(true);
        AzureADUserMgmtImpl.Run(ForUserSecurityId);
    end;
}