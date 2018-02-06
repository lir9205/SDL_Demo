//
//  main.m
//  LR_SDL_iOS_Demo
//
//  Created by admin on 2018/1/3.
//  Copyright © 2018年 lirui. All rights reserved.

//iOS原始 Main 入口
//#import <UIKit/UIKit.h>
//#import "AppDelegate.h"
//
//int main(int argc, char * argv[]) {
//    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
//    }
//}


//SDL 在 iOS 平台下的一段测试代码，说明了我们的环境配置是没有问题的，
//同时代码测试也是 OK 的，模拟器也能够运行，真机也是可以的
//#include <SDL.h>
//#include <stdio.h>
//#include <stdlib.h>
//#include <time.h>
//
//#define SCREEN_WIDTH 320
//#define SCREEN_HEIGHT 480
//
//int randomInt(int min, int max)
//{
//    return min + rand() % (max - min + 1);
//}
//
//void render(SDL_Renderer *renderer)
//{
//
//    SDL_Rect rect;
//    Uint8 r, g, b;
//
//    /* Clear the screen */
//    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
//    SDL_RenderClear(renderer);
//
//    /*  Come up with a random rectangle */
//    rect.w = randomInt(64, 128);
//    rect.h = randomInt(64, 128);
//    rect.x = randomInt(0, SCREEN_WIDTH);
//    rect.y = randomInt(0, SCREEN_HEIGHT);
//
//    /* Come up with a random color */
//    r = randomInt(50, 255);
//    g = randomInt(50, 255);
//    b = randomInt(50, 255);
//    SDL_SetRenderDrawColor(renderer, r, g, b, 255);
//
//    /*  Fill the rectangle in the color */
//    SDL_RenderFillRect(renderer, &rect);
//
//    /* update screen */
//    SDL_RenderPresent(renderer);
//}
//
//int main(int argc, char *argv[])
//{
//
//    SDL_Window *window;
//    SDL_Renderer *renderer;
//    int done;
//    SDL_Event event;
//
//    /* initialize SDL */
//    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
//        printf("Could not initialize SDL\n");
//        return 1;
//    }
//
//    /* seed random number generator */
//    srand(time(NULL));
//
//    /* create window and renderer */
//    window =
//    SDL_CreateWindow(NULL, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT,
//                     SDL_WINDOW_OPENGL);
//    if (!window) {
//        printf("Could not initialize Window\n");
//        return 1;
//    }
//
//    renderer = SDL_CreateRenderer(window, -1, 0);
//    if (!renderer) {
//        printf("Could not create renderer\n");
//        return 1;
//    }
//
//    /* Enter render loop, waiting for user to quit */
//    done = 0;
//    while (!done) {
//        while (SDL_PollEvent(&event)) {
//            if (event.type == SDL_QUIT) {
//                done = 1;
//            }
//        }
//        render(renderer);
//        SDL_Delay(1);
//    }
//
//    /* shutdown SDL */
//    SDL_Quit();
//
//    return 0;
//}

#import <UIKit/UIKit.h>
#import "SDL.h"

int main(int argc, char * argv[]) {
    
    //播放视频
    //第一步：初始化SDL多媒体框架
    if (SDL_Init( SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER ) == -1){
        printf("初始化失败");
        return -1;
    }
    
    //第二步：初始化SDL窗口
    //参数一：窗口名称
    //参数二：窗口在屏幕上的x坐标
    //参数三：窗口在屏幕上的y坐标
    //参数四：窗口在屏幕上宽
    int width = 640;
    //参数五：窗口在屏幕上高
    int height = 352;
    //参数六：窗口状态(打开)
    SDL_Window* sdl_window = SDL_CreateWindow("SDL播放YUV视频",
                                              SDL_WINDOWPOS_CENTERED,
                                              SDL_WINDOWPOS_CENTERED,
                                              width,
                                              height,
                                              SDL_WINDOW_OPENGL);
    if (sdl_window == NULL){
        printf("窗口创建失败");
        return -1;
    }
    
    //第三步：创建渲染器->渲染窗口
    //参数一：渲染目标创建->目标
    //参数二：从那里开始渲染(-1:表示从第一个位置开始)
    //参数三：渲染类型(软件渲染)
    SDL_Renderer* sdl_renderer = SDL_CreateRenderer(sdl_window, -1, 0);
    if (sdl_renderer == NULL){
        printf("渲染器创建失败");
        return -1;
    }
    
    //第四步：创建纹理
    //参数一：纹理->目标渲染器
    //参数二：渲染格式->YUV格式->像素数据格式(视频)或者是音频采样数据格式(音频)
    //参数三：绘制方式->频繁绘制->SDL_TEXTUREACCESS_STREAMING
    //参数四：纹理宽
    //参数五：纹理高
    SDL_Texture* sdl_texture = SDL_CreateTexture(sdl_renderer,
                                                 SDL_PIXELFORMAT_IYUV,
                                                 SDL_TEXTUREACCESS_STREAMING,
                                                 width,
                                                 height);
    if (sdl_texture == NULL){
        printf("纹理创建失败");
        return -1;
    }
    
    //第五步：设置纹理数据
    //第一点：打开yuv文件
    FILE* yuv_file = fopen("/Users/admin/Desktop/Mac/Test.yuv","rb+");
    if (yuv_file == NULL){
        printf("文件打开失败");
        return 0;
    }
    
    //第二点：循环读取yuv视频像素数据帧，渲染一帧数据
    //读取一帧视频像素数据，然后渲染一帧数据
    int y_size = width * height;
    
    //定义缓冲区(内存空间开辟多大?)
    //缓存一帧视频像素数据 = Y + U + V
    //Y:U:V = 4 : 1 : 1
    //假设：Y = 1.0  U = 0.25  V = 0.25
    //宽度：Y + U + V = 1.5
    //换算：Y + U + V = width * height * 1.5
    char buffer_pix[y_size * 3 / 2];
    
    
    //定义渲染器区域
    int current_index = 1;
    SDL_Rect sdl_rect;
    while (true){
        //1、一帧一帧的读取
        fread(buffer_pix, 1, y_size * 3 / 2, yuv_file);
        //判定是否读取完毕
        if (feof(yuv_file)){
            break;
        }
        
        NSLog(@"当前到了%zd帧", current_index);
        current_index++;
        
        //2、设置纹理数据
        //参数一：纹理
        //参数二：渲染区域
        //参数三：需要渲染数据->视频像素数据帧
        //参数四：帧宽
        SDL_UpdateTexture(sdl_texture, NULL, buffer_pix, width);
        
        //第六步：将纹理数据拷贝给渲染器
        //设置左上角位置(全屏)
        sdl_rect.x = 0;
        sdl_rect.y = 0;
        sdl_rect.w = width;
        sdl_rect.h = height;
        
        // 先清空原来的数据再渲染
        SDL_RenderClear(sdl_renderer);
        //参数一：渲染器
        //参数二：纹理
        //参数三：源渲染器区域，NULL代表整个区域
        //参数四：目标渲染的区域，NULL代表整个区域
        SDL_RenderCopy(sdl_renderer, sdl_texture, NULL, &sdl_rect);
        
        //第七步： 显示画面帧
        SDL_RenderPresent(sdl_renderer);
        
        //第八步：渲染每一帧直接间隔时间30ms
        SDL_Delay(30);
    }
    
    //第九步：释放资源
    fclose(yuv_file);
    SDL_DestroyTexture(sdl_texture);
    SDL_DestroyRenderer(sdl_renderer);
    
    //第十步：退出程序
    SDL_Quit();
    
    return 0;
}

