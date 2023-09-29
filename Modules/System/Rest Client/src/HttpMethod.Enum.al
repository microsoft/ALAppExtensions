// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.RestClient;

/// <summary>
/// This enum contains the REST Http Methods.
/// </summary>
enum 2350 "Http Method"
{
    Extensible = true;

    /// <summary>
    /// Specifies that the Http method is GET.
    /// </summary>
    value(0; GET)
    {
        Caption = 'GET', Locked = true;
    }

    /// <summary>
    /// Specifies that the Http method is POST.
    /// </summary>
    value(1; POST)
    {
        Caption = 'POST', Locked = true;
    }

    /// <summary>
    /// Specifies that the Http method is PATCH.
    /// </summary>
    value(2; PATCH)
    {
        Caption = 'PATCH', Locked = true;
    }

    /// <summary>
    /// Specifies that the Http method is PUT.
    /// </summary>
    value(3; PUT)
    {
        Caption = 'PUT', Locked = true;
    }

    /// <summary>
    /// Specifies that the Http method is DELETE.
    /// </summary>
    value(4; DELETE)
    {
        Caption = 'DELETE', Locked = true;
    }

    /// <summary>
    /// Specifies that the Http method is HEAD.
    /// </summary>
    value(5; HEAD)
    {
        Caption = 'HEAD', Locked = true;
    }

    /// <summary>
    /// Specifies that the Http method is OPTIONS.
    /// </summary>
    value(6; OPTIONS)
    {
        Caption = 'OPTIONS', Locked = true;
    }
}