//
//  LEColorPicker.m
//  LEColorPicker
//
//  Created by Luis Enrique Espinoza Severino on 10-12-12.
//  Copyright (c) 2012 Luis Espinoza. All rights reserved.
//

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LEColorPicker.h"
#import "UIColor+YUVSpace.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@implementation LEColorScheme
@end

@implementation LEColorPicker

@synthesize pastels = _pastels;

#pragma mark - Preprocessor definitions
#define LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE                           32
#define LECOLORPICKER_BACKGROUND_FILTER_TOLERANCE                       0.5
#define LECOLORPICKER_PRIMARY_TEXT_FILTER_TOLERANCE                     0.3
#define LECOLORPICKER_DEFAULT_COLOR_DIFFERENCE                          500
#define LECOLORPICKER_DEFAULT_BRIGHTNESS_DIFFERENCE                     125

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)


#pragma mark - C structures and constants
// Vertex structure
typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2];
} Vertex;

// LEColor structure
typedef struct {
    NSUInteger red;
    NSUInteger green;
    NSUInteger blue;
} LEColor;

// Add texture coordinates to Vertices as follows
const Vertex Vertices[] = {
    // Front
    {{1, -1, 0}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, 0}, {0, 1, 0, 1}, {1, 1}},
    {{-1, 1, 0}, {0, 0, 1, 1}, {0, 1}},
    {{-1, -1, 0}, {0, 0, 0, 1}, {0, 0}},
};

// Triangles coordinates
const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
};

//Vertex Shader string definition
NSString *const kDominantVertexShaderString = SHADER_STRING
(
 attribute vec4 Position;
 attribute vec4 SourceColor;
 
 varying vec4 DestinationColor;
 
 attribute vec2 TexCoordIn;
 varying vec2 TexCoordOut;
 
 void main(void) {
     DestinationColor = SourceColor;
     gl_Position = Position;
     TexCoordOut = TexCoordIn;
 }
 );

//Fragment Shader string definition
NSString *const kDominantFragmentShaderString = SHADER_STRING
(
 varying lowp vec4 DestinationColor;
 varying lowp vec2 TexCoordOut;
 uniform sampler2D Texture;
 uniform int ProccesedWidth;
 uniform int TotalWidth;
 
 void main(void) {
     lowp vec4 dummyColor = DestinationColor; //Dummy line for avoid WARNING from shader compiler
     lowp float accumulator = 0.0;
     lowp vec4 currentPixel = texture2D(Texture, TexCoordOut);
     highp float currentY = 0.299*currentPixel.r + 0.587*currentPixel.g+ 0.114*currentPixel.b;
     highp float currentU = (-0.14713)*currentPixel.r + (-0.28886)*currentPixel.g + (0.436)*currentPixel.b;
     highp float currentV = 0.615*currentPixel.r + (-0.51499)*currentPixel.g + (-0.10001)*currentPixel.b;
     highp vec3 currentYUV = vec3(currentY,currentU,currentV);
     lowp float d;
     if ((TexCoordOut.x > (float(ProccesedWidth)/float(TotalWidth))) || (TexCoordOut.y > (float(ProccesedWidth)/float(TotalWidth)))) {
         gl_FragColor = vec4(0.0,0.0,0.0,1.0);
     } else {
         accumulator = 0.0;
         for (int i=0; i<ProccesedWidth; i=i+1) {
             for (int j=0; j<ProccesedWidth; j=j+1) {
                 lowp vec2 coord = vec2(float(i)/float(TotalWidth),float(j)/float(TotalWidth));
                 lowp vec4 samplePixel = texture2D(Texture, coord);
                 
                 highp float sampleY = 0.299*samplePixel.r + 0.587*samplePixel.g+ 0.114*samplePixel.b;
                 highp float sampleU = (-0.14713)*samplePixel.r + (-0.28886)*samplePixel.g + (0.436)*samplePixel.b;
                 highp float sampleV = 0.615*samplePixel.r + (-0.51499)*samplePixel.g + (-0.10001)*samplePixel.b;
                 highp vec3 sampleYUV = vec3(sampleY,sampleU,sampleV);
                 
                 d = distance(sampleYUV,currentYUV);
                 
                 if (d < 0.1) {
                     accumulator = accumulator + 0.0039;
                 }
             }
         }
         gl_FragColor = vec4(currentPixel.r,currentPixel.g,currentPixel.b,accumulator);
     }
 }
 );

#pragma mark - C internal functions declaration (to avoid possible warnings)
/**
 Function for free output buffer data.
 **/
void freeImageData(void *info, const void *data, size_t size);

/**
 Function for calculating the square euclidian distance between 2 RGB colors in RGB space.
 @param colorA A RGB color.
 @param colorB Another RGB color.
 @return The square of euclidian distance in RGB space.
 */
NSUInteger squareDistanceInRGBSpaceBetweenColor(LEColor colorA, LEColor colorB);

#pragma mark - C internal functions implementation
void freeImageData(void *info, const void *data, size_t size)
{
    //printf("freeImageData called");
    free((void*)data);
}

NSUInteger squareDistanceInRGBSpaceBetweenColor(LEColor colorA, LEColor colorB)
{
    NSUInteger squareDistance = ((colorA.red - colorB.red)*(colorA.red - colorB.red))+
    ((colorA.green - colorB.green) * (colorA.green - colorB.green))+
    ((colorA.blue - colorB.blue) * (colorA.blue - colorB.blue));
    return squareDistance;
}

#pragma mark - Obj-C interface methods

- (id)init
{
    self = [super init];
    if (self) {
        // Create queue and set working flag initial state
        taskQueue = dispatch_queue_create("LEColorPickerQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(taskQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
        
        // Add notifications for multitasking and background aware
        [self addNotificationObservers];
    }
    return self;
}


- (void)pickColorsFromImage:(UIImage *)image
                 onComplete:(void (^)(LEColorScheme *colorsPickedDictionary))completeBlock
{
    if ([self isAppActive]) {
        dispatch_async(taskQueue, ^{
            // Color calculation process
            LEColorScheme *colorScheme = [self colorSchemeFromImage:image];
            
            // Call complete block and pass colors result
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(colorScheme);
            });
        });
    }
}

- (LEColorScheme*)colorSchemeFromImage:(UIImage*)inputImage
{
    if ([self isAppActive]) {
        // First, we scale the input image, to get a constant image size and square texture.
        UIImage *scaledImage = [self scaleImage:inputImage
                                          width:LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE
                                         height:LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE];
        
        // Now, We set the initial OpenGL ES 2.0 state.
        [self setupOpenGL];
        
        // Then we set the scaled image as the texture to render.
        _aTexture = [self setupTextureFromImage:scaledImage];
        
        // Now that all is ready, proceed we the render, to find the dominant color
        [self renderDominant];
        
        // Now that we have the rendered result, we start the color calculations.
        LEColorScheme *colorScheme = [[LEColorScheme alloc] init];
        colorScheme.backgroundColor = [self colorWithBiggerCountFromImageWidth:LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE height:LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE];
        
        // Now, find text colors
        [self findTextColorsTaskForColorScheme:colorScheme];
        
        colorScheme.primaryTextColor = [self closestPastelForColour:colorScheme.primaryTextColor];
        
        return colorScheme;
    }
    
    return nil;
}

#pragma mark - Old interface implementation
+ (void)pickColorFromImage:(UIImage *)image onComplete:(void (^)(NSDictionary *))completeBlock
{
    static LEColorPicker *colorPicker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorPicker = [[LEColorPicker alloc] init];
    });
    
    [colorPicker pickColorsFromImage:image onComplete:^(LEColorScheme *colorScheme) {
        NSDictionary *colorsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          colorScheme.backgroundColor,@"BackgroundColor",
                                          colorScheme.primaryTextColor,@"PrimaryTextColor",
                                          colorScheme.secondaryTextColor,@"SecondaryTextColor", nil];
        if ([NSThread isMainThread]) {
            completeBlock(colorsDictionary);
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                completeBlock(colorsDictionary);
            });
        }
    }];
}

#pragma mark - OpenGL ES 2 custom methods

- (void)setupOpenGL
{
    // Start openGLES
    
    if([self setupContext]){
        [self setupFrameBuffer];
        
        [self setupRenderBuffer];
        
        [self setupDepthBuffer];
        
        [self setupOpenGLForDominantColor];
        
        [self setupVBOs];
    }
}

- (void)renderDominant
{
    //start up
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ZERO);
    glEnable(GL_TEXTURE_2D);
    
    //Setup inputs
    glViewport(0, 0, LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE, LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    
    glUniform1i(_proccesedWidthSlot, LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE/2);
    glUniform1i(_totalWidthSlot, LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _aTexture);
    glUniform1i(_textureUniform, 0);
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
}

- (GLuint)setupTextureFromImage:(UIImage*)image
{
    // Get core graphics image reference
    CGImageRef inputTextureImage = image.CGImage;
    
    if (!inputTextureImage) {
        LELog(@"Failed to load image for texture");
    }
    
    NSUInteger width = CGImageGetWidth(inputTextureImage);
    NSUInteger height = CGImageGetHeight(inputTextureImage);
    
    GLubyte *inputTextureData = (GLubyte*)calloc(width*height*4, sizeof(GLubyte));
    CGColorSpaceRef inputTextureColorSpace = CGImageGetColorSpace(inputTextureImage);
    CGContextRef inputTextureContext = CGBitmapContextCreate(inputTextureData,
                                                             width, height,
                                                             8, width*4,
                                                             inputTextureColorSpace,
                                                             (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    //3 Draw image into the context
    CGContextDrawImage(inputTextureContext, CGRectMake(0, 0, width, height),inputTextureImage);
    CGContextRelease(inputTextureContext);
    
    
    //4 Send the pixel data to OpenGL
    GLuint inputTexName;
    glGenTextures(1, &inputTexName);
    glBindTexture(GL_TEXTURE_2D, inputTexName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexImage2D(GL_TEXTURE_2D, 0,GL_RGBA , (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, inputTextureData);
    free(inputTextureData);
    return inputTexName;
}

- (BOOL)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    if (_context == NULL) {
        _context = [[EAGLContext alloc] initWithAPI:api];
        if (!_context) {
            NSLog(@"Failed to initialize OpenGLES 2.0 context");
            return NO;
        }
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        return NO;
    }
    
    return YES;
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
}


- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE, LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE , LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}


- (void)setupVBOs {
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (BOOL)setupOpenGLForDominantColor
{
    GLuint vertShader, fragShader;
    
    // Create and compile vertex shader.
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER string:kDominantVertexShaderString]) {
        LELog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER string:kDominantFragmentShaderString]) {
        LELog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Link program.
    if (![self linkProgram:_program]) {
        LELog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        return NO;
    }
    
    glUseProgram(_program);
    
    //Get attributes locations
    _positionSlot = glGetAttribLocation(_program, "Position");
    _colorSlot = glGetAttribLocation(_program, "SourceColor");
    _texCoordSlot = glGetAttribLocation(_program, "TexCoordIn");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texCoordSlot);
    
    _textureUniform = glGetUniformLocation(_program, "Texture");
    _proccesedWidthSlot = glGetUniformLocation(_program, "ProccesedWidth");
    _totalWidthSlot = glGetUniformLocation(_program, "TotalWidth");
    return YES;
}



#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type string:(NSString *)string
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[string UTF8String];
    if (!source) {
        LELog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#ifdef LE_DEBUG
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#ifdef LE_DEBUG
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        LELog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


#pragma mark - Convert GL image to UIImage
-(UIImage *)dumpImageWithWidth:(NSUInteger)width height:(NSUInteger)height biggestAlphaColorReturn:(UIColor**)returnColor
{
    GLubyte *buffer = (GLubyte *) malloc(width * height * 4);
    glReadPixels(0, 0, (int)width, (int)height, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)buffer);
    
    /* Find bigger Alpha color*/
    NSUInteger biggerR = 0;
    NSUInteger biggerG = 0;
    NSUInteger biggerB = 0;
    NSUInteger biggerAlpha = 0;
    
    for (NSUInteger y=0; y<(height/2); y++) {
        for (NSUInteger x=0; x<(width/2)*4; x++) {
            if ((!((x+1)%4)) && (x>0)) {
                if (buffer[y * 4 * width + x] > biggerAlpha ) {
                    biggerAlpha = buffer[y * 4 * width + x];
                    biggerR = buffer[y * 4 * width + (x-3)];
                    biggerG = buffer[y * 4 * width + (x-2)];
                    biggerB = buffer[y * 4 * width + (x-1)];
                }
            }
        }
    }
    
    *returnColor = [UIColor colorWithRed:biggerR/255.0
                                   green:biggerG/255.0
                                    blue:biggerB/255.0
                                   alpha:1.0];
    
    // make data provider from buffer
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, width * height * 4, freeImageData);
    
    // set up for CGImage creation
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * (int)width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    
    // Use this to retain alpha
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // make UIImage from CGImage
    UIImage *newUIImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    
    return newUIImage;
}

-(UIColor *)colorWithBiggerCountFromImageWidth:(NSUInteger)width height:(NSUInteger)height
{
    GLubyte *buffer = (GLubyte *) malloc(width * height * 4);
    glReadPixels(0, 0, (int)width, (int)height, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)buffer);
    
    /* Find bigger Alpha color*/
    NSUInteger biggerR = 0;
    NSUInteger biggerG = 0;
    NSUInteger biggerB = 0;
    NSUInteger biggerAlpha = 0;
    
    for (NSUInteger y=0; y<(height/2); y++) {
        for (NSUInteger x=0; x<(width/2)*4; x++) {
            if ((!((x+1)%4)) && (x>0)) {
                if (buffer[y * 4 * width + x] > biggerAlpha ) {
                    biggerAlpha = buffer[y * 4 * width + x];
                    biggerR = buffer[y * 4 * width + (x-3)];
                    biggerG = buffer[y * 4 * width + (x-2)];
                    biggerB = buffer[y * 4 * width + (x-1)];
                }
            }
        }
    }
    
    free(buffer);
    
    return [UIColor colorWithRed:biggerR/255.0
                           green:biggerG/255.0
                            blue:biggerB/255.0
                           alpha:1.0];
}

-(UIColor *)colorFromImageWithWidth:(NSUInteger)width
                             height:(NSUInteger)height
                     filteringColor:(UIColor*)colorToFilter
                          tolerance:(GLfloat)tolerance
{
    GLubyte *buffer = (GLubyte *) malloc(width * height * 4);
    
    glReadPixels(0, 0, (int)width, (int)height, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)buffer);
    
    /* Find bigger Alpha color*/
    NSUInteger biggerR = 0;
    NSUInteger biggerG = 0;
    NSUInteger biggerB = 0;
    NSUInteger biggerAlpha = 0;
    CGFloat filteringRedFloat = 0;
    CGFloat filteringGreenFloat = 0;
    CGFloat filteringBlueFloat = 0;
    
    [colorToFilter getRed:&filteringRedFloat
                    green:&filteringGreenFloat
                     blue:&filteringBlueFloat
                    alpha:nil];
    
    NSUInteger filteringRed = (NSUInteger)(filteringRedFloat*255);
    NSUInteger filteringGreen = (NSUInteger)(filteringGreenFloat*255);
    NSUInteger filteringBlue = (NSUInteger)(filteringBlueFloat*255);
    
    for (NSUInteger y=0; y<(height/2); y++) {
        for (NSUInteger x=0; x<(width/2)*4; x++) {
            if ((!((x+1)%4)) && (x>0)) {
                NSUInteger currentRed = buffer[y * 4 * width + (x-3)];
                NSUInteger currentGreen = buffer[y * 4 * width + (x-2)];
                NSUInteger currentBlue = buffer[y * 4 * width + (x-1)];
                
                NSUInteger squareDistance = (currentRed-filteringRed)*(currentRed-filteringRed)+
                (currentGreen-filteringGreen)*(currentGreen-filteringGreen)+
                (currentBlue-filteringBlue)*(currentBlue-filteringBlue);
                
                NSUInteger thresholdSquareDistance = (255*tolerance)*(255*tolerance);
                
                if (squareDistance > thresholdSquareDistance) {
                    if (buffer[y * 4 * width + x] > biggerAlpha ) {
                        
                        biggerAlpha = buffer[y * 4 * width + x];
                        biggerR = buffer[y * 4 * width + (x-3)];
                        biggerG = buffer[y * 4 * width + (x-2)];
                        biggerB = buffer[y * 4 * width + (x-1)];
                    }
                }
            }
        }
    }
    
    free(buffer);
    
    return [UIColor colorWithRed:biggerR/255.0
                           green:biggerG/255.0
                            blue:biggerB/255.0
                           alpha:1.0];
}

-(void)findTextColorsTaskForColorScheme:(LEColorScheme*)colorScheme
{
    //Set sizes for buffer index calculations
    int width = LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE;
    int height = LECOLORPICKER_GPU_DEFAULT_SCALED_SIZE;
    
    //Read Render buffer
    GLubyte *buffer = (GLubyte *) malloc(width * height * 4);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)buffer);
    
    //Set initials values for local variables
    NSUInteger primaryColorR = 0;
    NSUInteger primaryColorG = 0;
    NSUInteger primaryColorB = 0;
    NSUInteger primaryColorAlpha = 0;
    
    CGFloat backgroundRedFloat = 0;
    CGFloat backgroundGreenFloat = 0;
    CGFloat backgroundBlueFloat = 0;
    
    [colorScheme.backgroundColor getRed:&backgroundRedFloat
                                  green:&backgroundGreenFloat
                                   blue:&backgroundBlueFloat
                                  alpha:nil];
    
    LEColor backgroundColor = {(unsigned int)(backgroundRedFloat*255),
        (unsigned int)(backgroundGreenFloat*255),
        (unsigned int)(backgroundBlueFloat*255)};
    
    for (NSUInteger y=0; y<(height/2); y++) {
        for (NSUInteger x=0; x<(width/2)*4; x++) {
            if ((!((x+1)%4)) && (x>0)) {
                NSUInteger currentRed = buffer[y * 4 * width + (x-3)];
                NSUInteger currentGreen = buffer[y * 4 * width + (x-2)];
                NSUInteger currentBlue = buffer[y * 4 * width + (x-1)];
                
                LEColor currentColor = {currentRed,currentGreen,currentBlue};
                NSUInteger squareDistance = squareDistanceInRGBSpaceBetweenColor(currentColor, backgroundColor);
                NSUInteger thresholdSquareDistance = (255*LECOLORPICKER_BACKGROUND_FILTER_TOLERANCE)*(255*LECOLORPICKER_BACKGROUND_FILTER_TOLERANCE);
                
                if (squareDistance > thresholdSquareDistance) {
                    if (buffer[y * 4 * width + x] > primaryColorAlpha ) {
                        
                        primaryColorAlpha = buffer[y * 4 * width + x];
                        primaryColorR = buffer[y * 4 * width + (x-3)];
                        primaryColorG = buffer[y * 4 * width + (x-2)];
                        primaryColorB = buffer[y * 4 * width + (x-1)];
                    }
                }
            }
        }
    }
    
    UIColor *tmpColor = [UIColor colorWithRed:primaryColorR/255.0
                                        green:primaryColorG/255.0
                                         blue:primaryColorB/255.0
                                        alpha:1.0];
    
    colorScheme.primaryTextColor = tmpColor;
    
    NSUInteger secondaryColorR = 0;
    NSUInteger secondaryColorG = 0;
    NSUInteger secondaryColorB = 0;
    NSUInteger secondaryColorAlpha = 0;
    
    LEColor primaryTextColor = {primaryColorR,primaryColorG,primaryColorB};
    for (NSUInteger y=0; y<(height/2); y++) {
        for (NSUInteger x=0; x<(width/2)*4; x++) {
            if ((!((x+1)%4)) && (x>0)) {
                NSUInteger currentRed = buffer[y * 4 * width + (x-3)];
                NSUInteger currentGreen = buffer[y * 4 * width + (x-2)];
                NSUInteger currentBlue = buffer[y * 4 * width + (x-1)];
                
                LEColor currentColor = {currentRed,currentGreen,currentBlue};
                NSUInteger squareDistanceToBackground = squareDistanceInRGBSpaceBetweenColor(currentColor, backgroundColor);
                NSUInteger squareDistanceToPrimary = squareDistanceInRGBSpaceBetweenColor(currentColor, primaryTextColor);
                NSUInteger thresholdSquareDistanceToBackground = (255*LECOLORPICKER_BACKGROUND_FILTER_TOLERANCE)*(255*LECOLORPICKER_BACKGROUND_FILTER_TOLERANCE);
                NSUInteger thresholdSquareDistanceToPrimary = (255*LECOLORPICKER_PRIMARY_TEXT_FILTER_TOLERANCE)*(255*LECOLORPICKER_PRIMARY_TEXT_FILTER_TOLERANCE);
                if ((squareDistanceToBackground > thresholdSquareDistanceToBackground) && (squareDistanceToPrimary > thresholdSquareDistanceToPrimary)) {
                    if (buffer[y * 4 * width + x] > secondaryColorAlpha ) {
                        secondaryColorAlpha = buffer[y * 4 * width + x];
                        secondaryColorR = buffer[y * 4 * width + (x-3)];
                        secondaryColorG = buffer[y * 4 * width + (x-2)];
                        secondaryColorB = buffer[y * 4 * width + (x-1)];
                    }
                }
            }
        }
    }
    
    tmpColor = [UIColor colorWithRed:secondaryColorR/255.0
                               green:secondaryColorG/255.0
                                blue:secondaryColorB/255.0
                               alpha:1.0];
    
    if ([self isSufficienteContrastBetweenBackground:colorScheme.backgroundColor
                                        andForground:tmpColor]) {
        colorScheme.secondaryTextColor = tmpColor;
    } else {
        if ([UIColor yComponentFromColor:colorScheme.backgroundColor] < 0.5) {
            colorScheme.secondaryTextColor = [UIColor whiteColor];
        } else {
            colorScheme.secondaryTextColor = [UIColor blackColor];
        }
    }
    
    free(buffer);
}

- (UIImage*)scaleImage:(UIImage*)image width:(CGFloat)width height:(CGFloat)height
{
    UIImage *scaledImage =  [self imageWithImage:image scaledToSize:CGSizeMake(width,height)];
    return scaledImage;
}

- (BOOL)isSufficienteContrastBetweenBackground:(UIColor*)backgroundColor andForground:(UIColor*)foregroundColor
{
    float backgroundColorBrightness = [UIColor yComponentFromColor:backgroundColor];
    float foregroundColorBrightness = [UIColor yComponentFromColor:foregroundColor];
    float brightnessDifference = fabsf(backgroundColorBrightness-foregroundColorBrightness)*255;
    
    LELog(@"BrightnessDifference %f ",brightnessDifference);
    
    if (brightnessDifference>=LECOLORPICKER_DEFAULT_BRIGHTNESS_DIFFERENCE) {
        float backgroundRed = 0.0;
        float backgroundGreen = 0.0;
        float backgroundBlue = 0.0;
        float foregroundRed = 0.0;
        float foregroundGreen = 0.0;
        float foregroundBlue = 0.0;
        
        size_t numComponents = CGColorGetNumberOfComponents(backgroundColor.CGColor);
        
        if (numComponents == 4) {
            const CGFloat *components = CGColorGetComponents(backgroundColor.CGColor);
            backgroundRed = components[0];
            backgroundGreen = components[1];
            backgroundBlue = components[2];
        }
        
        numComponents = CGColorGetNumberOfComponents(foregroundColor.CGColor);
        
        if (numComponents == 4) {
            const CGFloat *components = CGColorGetComponents(foregroundColor.CGColor);
            foregroundRed = components[0];
            foregroundGreen = components[1];
            foregroundBlue = components[2];
        }
        
        //Compute "Color Diference"
        float colorDifference = (MAX(backgroundRed,foregroundRed)-MIN(backgroundRed, foregroundRed)) +
        (MAX(backgroundGreen,foregroundGreen)-MIN(backgroundGreen, foregroundGreen)) +
        (MAX(backgroundBlue,foregroundBlue)-MIN(backgroundBlue, foregroundBlue));
        LELog(@"ColorDifference = %f",colorDifference*255);
        if ((colorDifference*255)>LECOLORPICKER_DEFAULT_COLOR_DIFFERENCE) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - UIImage utilities
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Multitasking and Background aware
- (void)addNotificationObservers
{
    // Add observers for notification to respond at app state changes.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

-(NSArray*) pastels
{
    if(!_pastels){
        _pastels = @[
          @{@"r":@(210),@"g":@(77),@"b":@(87)},
          @{@"r":@(242),@"g":@(38),@"b":@(19)},
          @{@"r":@(255),@"g":@(0),@"b":@(0)},
          @{@"r":@(217),@"g":@(30),@"b":@(24)},
          @{@"r":@(150),@"g":@(40),@"b":@(27)},
          @{@"r":@(239),@"g":@(72),@"b":@(54)},
          @{@"r":@(214),@"g":@(69),@"b":@(65)},
          @{@"r":@(192),@"g":@(57),@"b":@(43)},
          @{@"r":@(207),@"g":@(0),@"b":@(15)},
          @{@"r":@(231),@"g":@(76),@"b":@(60)},
          @{@"r":@(219),@"g":@(10),@"b":@(91)},
          @{@"r":@(255),@"g":@(236),@"b":@(219)},
          @{@"r":@(246),@"g":@(71),@"b":@(71)},
          @{@"r":@(241),@"g":@(169),@"b":@(160)},
          @{@"r":@(210),@"g":@(82),@"b":@(127)},
          @{@"r":@(224),@"g":@(130),@"b":@(131)},
          @{@"r":@(246),@"g":@(36),@"b":@(89)},
          @{@"r":@(226),@"g":@(106),@"b":@(106)},
          @{@"r":@(220),@"g":@(198),@"b":@(224)},
          @{@"r":@(102),@"g":@(51),@"b":@(153)},
          @{@"r":@(103),@"g":@(65),@"b":@(114)},
          @{@"r":@(174),@"g":@(168),@"b":@(211)},
          @{@"r":@(145),@"g":@(61),@"b":@(136)},
          @{@"r":@(154),@"g":@(18),@"b":@(179)},
          @{@"r":@(191),@"g":@(85),@"b":@(236)},
          @{@"r":@(190),@"g":@(144),@"b":@(212)},
          @{@"r":@(142),@"g":@(68),@"b":@(173)},
          @{@"r":@(155),@"g":@(89),@"b":@(182)},
          @{@"r":@(228),@"g":@(241),@"b":@(254)},
          @{@"r":@(65),@"g":@(131),@"b":@(215)},
          @{@"r":@(89),@"g":@(171),@"b":@(227)},
          @{@"r":@(129),@"g":@(207),@"b":@(224)},
          @{@"r":@(82),@"g":@(179),@"b":@(217)},
          @{@"r":@(197),@"g":@(239),@"b":@(247)},
          @{@"r":@(34),@"g":@(167),@"b":@(240)},
          @{@"r":@(52),@"g":@(152),@"b":@(219)},
          @{@"r":@(44),@"g":@(62),@"b":@(80)},
          @{@"r":@(25),@"g":@(181),@"b":@(254)},
          @{@"r":@(51),@"g":@(110),@"b":@(123)},
          @{@"r":@(34),@"g":@(49),@"b":@(63)},
          @{@"r":@(107),@"g":@(185),@"b":@(240)},
          @{@"r":@(30),@"g":@(139),@"b":@(195)},
          @{@"r":@(58),@"g":@(83),@"b":@(155)},
          @{@"r":@(52),@"g":@(73),@"b":@(94)},
          @{@"r":@(103),@"g":@(128),@"b":@(159)},
          @{@"r":@(37),@"g":@(116),@"b":@(169)},
          @{@"r":@(31),@"g":@(58),@"b":@(147)},
          @{@"r":@(137),@"g":@(196),@"b":@(244)},
          @{@"r":@(75),@"g":@(119),@"b":@(190)},
          @{@"r":@(92),@"g":@(151),@"b":@(191)},
          @{@"r":@(162),@"g":@(222),@"b":@(208)},
          @{@"r":@(135),@"g":@(211),@"b":@(124)},
          @{@"r":@(144),@"g":@(198),@"b":@(149)},
          @{@"r":@(38),@"g":@(166),@"b":@(91)},
          @{@"r":@(3),@"g":@(201),@"b":@(169)},
          @{@"r":@(104),@"g":@(195),@"b":@(163)},
          @{@"r":@(101),@"g":@(198),@"b":@(187)},
          @{@"r":@(27),@"g":@(188),@"b":@(155)},
          @{@"r":@(27),@"g":@(163),@"b":@(156)},
          @{@"r":@(102),@"g":@(204),@"b":@(153)},
          @{@"r":@(54),@"g":@(215),@"b":@(183)},
          @{@"r":@(200),@"g":@(247),@"b":@(197)},
          @{@"r":@(134),@"g":@(226),@"b":@(213)},
          @{@"r":@(46),@"g":@(204),@"b":@(113)},
          @{@"r":@(22),@"g":@(160),@"b":@(133)},
          @{@"r":@(63),@"g":@(195),@"b":@(128)},
          @{@"r":@(1),@"g":@(152),@"b":@(117)},
          @{@"r":@(3),@"g":@(166),@"b":@(120)},
          @{@"r":@(77),@"g":@(175),@"b":@(124)},
          @{@"r":@(42),@"g":@(187),@"b":@(155)},
          @{@"r":@(0),@"g":@(177),@"b":@(106)},
          @{@"r":@(30),@"g":@(130),@"b":@(76)},
          @{@"r":@(4),@"g":@(147),@"b":@(114)},
          @{@"r":@(38),@"g":@(194),@"b":@(129)},
          @{@"r":@(245),@"g":@(215),@"b":@(110)},
          @{@"r":@(247),@"g":@(202),@"b":@(24)},
          @{@"r":@(244),@"g":@(208),@"b":@(63)},
          @{@"r":@(253),@"g":@(227),@"b":@(167)},
          @{@"r":@(248),@"g":@(148),@"b":@(6)},
          @{@"r":@(235),@"g":@(149),@"b":@(50)},
          @{@"r":@(232),@"g":@(126),@"b":@(4)},
          @{@"r":@(244),@"g":@(179),@"b":@(80)},
          @{@"r":@(242),@"g":@(120),@"b":@(75)},
          @{@"r":@(235),@"g":@(151),@"b":@(78)},
          @{@"r":@(245),@"g":@(171),@"b":@(53)},
          @{@"r":@(211),@"g":@(84),@"b":@(0)},
          @{@"r":@(243),@"g":@(156),@"b":@(18)},
          @{@"r":@(249),@"g":@(105),@"b":@(14)},
          @{@"r":@(249),@"g":@(191),@"b":@(59)},
          @{@"r":@(242),@"g":@(121),@"b":@(53)},
          @{@"r":@(230),@"g":@(126),@"b":@(34)},
          @{@"r":@(108),@"g":@(122),@"b":@(137)},
          @{@"r":@(210),@"g":@(215),@"b":@(211)},
          @{@"r":@(238),@"g":@(238),@"b":@(238)},
          @{@"r":@(189),@"g":@(195),@"b":@(199)},
          @{@"r":@(236),@"g":@(240),@"b":@(241)},
          @{@"r":@(149),@"g":@(165),@"b":@(166)},
          @{@"r":@(218),@"g":@(223),@"b":@(225)},
          @{@"r":@(171),@"g":@(183),@"b":@(183)},
          @{@"r":@(242),@"g":@(241),@"b":@(239)},
          @{@"r":@(191),@"g":@(191),@"b":@(191)},
          ];
    }
    
    return _pastels;
}

-(UIColor*) closestPastelForColour:(UIColor*) colour
{
    
    float r1, g1, b1, distance = 10000000;
    int index = 0;
    
    if ([colour getRed:&r1 green:&g1 blue:&b1 alpha:NULL])
    {
        for (int i = 0; i < [self.pastels count]; i++) {
            
            NSDictionary *c = self.pastels[i];
  
            float r2 = [c[@"r"] intValue] / 255.0f, g2 = [c[@"g"] intValue] / 255.0f, b2 = [c[@"b"] intValue] / 255.0f;
            double dy = pow((r1-r2), 2.0f) + pow((g1-g2), 2.0f) + pow((b1-b2), 2.0f);
        
            if (fabs(dy) < distance)
            {
                index = i;
                distance = dy;
            }
        }
    }
    
    NSDictionary *o = self.pastels[(int)index];
    
    return [UIColor colorWithRed:[o[@"r"] intValue]/255.0f green:[o[@"g"] intValue]/255.0f blue:[o[@"b"] intValue]/255.0f alpha:1.0f];
    
}

- (void)dealloc {
    
    //Remove all observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

}

- (void)appDidEnterBackground
{
    dispatch_suspend(taskQueue);
    glFinish();
}

- (void)appDidEnterForeground
{
    dispatch_resume(taskQueue);
}

- (BOOL)isAppActive
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateBackground)
    {
        return NO;
    }
    
    return YES;
}
@end
