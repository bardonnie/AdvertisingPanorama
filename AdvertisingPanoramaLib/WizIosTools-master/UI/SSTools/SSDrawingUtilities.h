//
//  SSDrawingUtilities.h
//  SSToolkit
//
//  Created by Sam Soffes on 4/22/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#ifndef SSDRAWINGUTILITIES
#define SSDRAWINGUTILITIES

///-----------------------------------
/// @name Degree and Radian Conversion
///-----------------------------------

/**
 A macro that converts a number from degress to radians.
 
 @param d number in degrees
 
 @return The number converted to radians.
 */
#define DEGREES_TO_RADIANS(d) ((d) * 0.0174532925199432958f)

/**
 A macro that converts a number from radians to degrees.
 
 @param r number in radians
 
 @return The number converted to degrees.
 */
#define RADIANS_TO_DEGREES(r) ((r) * 57.29577951308232f)

#endif

/**
 Limits a float to the `min` or `max` value. The float is between `min` and `max` it will be returned unchanged.
 
 @param f The float to limit.
 
 @param min The minumum value for the float.
 
 @param max The minumum value for the float.
 
 @return A float limited to the `min` or `max` value.
 */
#ifdef __cplusplus

extern "C"
{
#endif
     CGRect CGRectSetX(CGRect rect, CGFloat x);
     CGRect CGRectSetY(CGRect rect, CGFloat y);
     CGRect CGRectSetWidth(CGRect rect, CGFloat width);
     CGRect CGRectSetHeight(CGRect rect, CGFloat height);
     CGRect CGRectSetOrigin(CGRect rect, CGPoint origin);
     CGRect CGRectSetSize(CGRect rect, CGSize size);
     CGRect CGRectSetZeroOrigin(CGRect rect);
     CGRect CGRectSetZeroSize(CGRect rect);
     CGSize CGSizeAspectScaleToSize(CGSize size, CGSize toSize);
     CGRect CGRectAddPoint(CGRect rect, CGPoint point);
    
    
    ///---------------------------------
    /// @name Drawing Rounded Rectangles
    ///---------------------------------
    
     void SSDrawRoundedRect(CGContextRef context, CGRect rect, CGFloat cornerRadius);
    
    
    ///-------------------------
    /// @name Creating Gradients
    ///-------------------------
    
     CGGradientRef SSCreateGradientWithColors(NSArray *colors);
     CGGradientRef SSCreateGradientWithColorsAndLocations(NSArray *colors, NSArray *locations);
    
    
    ///------------------------
    /// @name Drawing Gradients
    ///------------------------
    
     void SSDrawGradientInRect(CGContextRef context, CGGradientRef gradient, CGRect rect);
    CGFloat SSFLimit(CGFloat f, CGFloat min, CGFloat max);


#ifdef __cplusplus
}
#endif


///-----------------------------
/// @name Rectangle Manipulation
///-----------------------------

