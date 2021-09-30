// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for working with images.
/// </summary>
codeunit 3971 Image
{
    Access = Public;

    var
        ImageImpl: Codeunit "Image Impl.";

    /// <summary>
    /// Crops the image based on a rectangle specified by the user. 
    /// The resulting crop will be a hole-cut in the image made by the rectangle.
    /// </summary>
    /// <param name="X">X coordinate of the rectangle.</param>
    /// <param name="Y">Y coordinate of the rectangle.</param>
    /// <param name="Width">Width of rectangle.</param>
    /// <param name="Height">Height of the rectangle./</param>
    /// <remarks>The Rectangles top left corner has to be within the image dimensions, 
    /// but specifying a width or height that makes the rectangle go outside the image dimensions is allowed.   
    /// Anything outside the image dimensions will be filled with the image background color.</remarks>
    /// <error>X and Y is not within the image dimensions.</error>
    /// <error>Width and Height is less than one.</error>
    procedure Crop(X: Integer; Y: Integer; Width: Integer; Height: Integer)
    begin
        ImageImpl.Crop(X, Y, Width, Height);
    end;

    /// <summary>
    /// Gets the image format as a text.
    /// </summary>
    /// <returns>A text containing the format value.</returns>
    procedure GetFormatAsText(): Text
    begin
        exit(ImageImpl.GetFormatAsString());
    end;

    /// <summary>
    /// Gets the image format as an Enum "Image Format".
    /// </summary>
    /// <returns>The enum value.</returns>
    procedure GetFormat(): Enum "Image Format"
    begin
        exit(ImageImpl.GetFormat());
    end;

    /// <summary>
    /// Creates an Image from base64 encoding.
    /// </summary>
    /// <param name="Base64Text">A base64 encoded string the contains the image.</param>
    procedure FromBase64(Base64Text: Text)
    begin
        ImageImpl.FromBase64(Base64Text);
    end;

    /// <summary>
    /// Creates an image from the specified data stream.
    /// </summary>
    /// <param name="InStream">A Stream that contains the image data.</param>
    /// <error>Stream do not contain valid image data</error>
    procedure FromStream(InStream: InStream)
    begin
        ImageImpl.FromStream(InStream);
    end;

    /// <summary>
    /// Gets the width in pixels.
    /// </summary>
    /// <returns>The width in pixels.</returns>
    procedure GetWidth(): Integer
    begin
        exit(ImageImpl.GetWidth());
    end;

    /// <summary>
    /// Gets the height in pixels.
    /// </summary>
    /// <returns>The height in pixels.</returns>
    procedure GetHeight(): Integer
    begin
        exit(ImageImpl.GetHeight());
    end;

    /// <summary>
    /// Resizes the Image to the specified size.
    /// </summary>
    /// <param name="Width">The resize width.</param>
    /// <param name="Height">The resize height.</param>
    /// <error>Width and Height is less than one.</error>
    procedure Resize(Width: Integer; Height: Integer)
    begin
        ImageImpl.Resize(Width, Height);
    end;

    /// <summary>
    /// Saves the image to the specified stream in the specified format.
    /// </summary>
    /// <param name="OutStream">A Stream that will store the image data.</param>
    procedure Save(OutStream: OutStream)
    begin
        ImageImpl.Save(OutStream);
    end;

    /// <summary>
    /// Convert the image to a base64 encoded string.
    /// </summary>
    /// <returns>A string containing the image data encoded with base64.</returns>
    procedure ToBase64(): Text
    begin
        exit(ImageImpl.ToBase64());
    end;

}