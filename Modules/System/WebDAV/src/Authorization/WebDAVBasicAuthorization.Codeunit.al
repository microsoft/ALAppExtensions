// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 5680 "WebDAV Basic Authorization"
{
    Access = Public;

    /// <summary>
    /// GetWebDAVBasicAuth.
    /// </summary>
    /// <param name="Username">Text.</param>
    /// <param name="Password">Text.</param>
    /// <returns>Return value of type Interface "WebDAV Authorization".</returns>
    procedure GetWebDAVBasicAuth(Username: Text; Password: Text): Interface "WebDAV Authorization"
    var
        WebDAVBasicAuthImpl: Codeunit "WebDAV Basic Auth. Impl.";
    begin
        WebDAVBasicAuthImpl.SetUserNameAndPassword(Username, Password);
        exit(WebDAVBasicAuthImpl);
    end;

}