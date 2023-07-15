//
//  ContentView.swift
//  PinchApp
//
//  Created by Matteo Buompastore on 15/07/23.
//

import SwiftUI

struct ContentView: View {
    
    //MARK: - PROPERTY
    @State private var isAnimating = false
    @State private var imageScale : CGFloat = 1
    @State private var imageOffset : CGSize = .zero //CGSize(width: 0, height: 0)
    @State private var isDrawerOpen = false
    
    let pages : [Page] = pageData
    @State private var pageIndex : Int = 1
    
    //MARK: FUNCTIONS
    func resetImageState() {
        withAnimation(.spring(response: 1, dampingFraction: 0.8)) {
            imageOffset = .zero
            imageScale = 1
        }
    }
    
    func closeDrawer() {
        withAnimation {
            isDrawerOpen = false
        }
    }
    
    func currentPage() -> String {
        return pages[pageIndex - 1].imageName
    }
    
    //MARK: CONTENT
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color.clear
                
                //MARK: - PAGE IMAGE
                Image(currentPage())
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .padding()
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 2, y: 2)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(x: imageOffset.width, y: imageOffset.height)
                    .animation(.linear(duration: 1), value: isAnimating)
                    .scaleEffect(imageScale)
                    .onTapGesture(count: 2) {
                        closeDrawer()
                        withAnimation(.spring()) {
                            //Applies a 5X magnification on double tap or resets the scale
                            imageScale = imageScale == 1 ? 5 : 1
                            
                            //If the scale of the image is 1 the offset is reset
                            imageOffset = imageScale == 1 ? .zero : imageOffset
                        }
                    }
                    .gesture(DragGesture().onChanged{ gesture in
                        closeDrawer()
                        withAnimation(.linear(duration: 0.3)) {
                            imageOffset = gesture.translation
                        }
                    }.onEnded{ _ in
                        if(imageScale <= 1) {
                            resetImageState()
                        }
                    })
                //MARK: - MAGNIFICATION
                    .gesture(MagnificationGesture().onChanged{ value in
                        withAnimation(.linear) {
                            if imageScale >= 1 && imageScale <= 5 {
                                imageScale = value
                            } else if imageScale > 5 {
                                imageScale = 5
                            }
                        }
                    }.onEnded{ value in
                        withAnimation(.linear) {
                            if imageScale > 5 {
                                imageScale = 5
                            } else if imageScale < 1 {
                                resetImageState()
                            }
                        }
                    })
            }//: ZSTACK
            .navigationTitle("Pinch & Zoom")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isAnimating = true
            }
            //MARK: - INFO PANEL
            .overlay(
                InfoPanelView(scale: imageScale, offset: imageOffset)
                    .padding(.horizontal)
                    .padding(.top)
                ,alignment: .top
            )
            //MARK: - CONTROLS
            .overlay(
                controlGroup
                .padding(.bottom, 30)
                , alignment: .bottom
            )
            //MARK: - DRAWER
            .overlay(
                HStack(spacing: 12) {
                    //MARK: - DRAWER HANDLE
                    Image(systemName: "chevron.compact.\(isDrawerOpen ? "right" : "left")")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .padding(8)
                        .foregroundStyle(.secondary)
                        .onTapGesture {
                            withAnimation(.easeOut) {
                                isDrawerOpen.toggle()
                            }
                        }
                    //MARK: - THUMBNAILS
                    ForEach(pages) { page in
                        Image(page.thumbnailName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                            .opacity(isDrawerOpen ? 1 : 0)
                            .animation(.easeOut, value: isDrawerOpen)
                            .onTapGesture {
                                withAnimation {
                                    pageIndex = page.id
                                    isAnimating = true
                                }
                            }
                    }
                    Spacer()
                }
                    .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .opacity(isAnimating ? 1 : 0)
                    .frame(width: 260)
                    .padding(.top, UIScreen.main.bounds.height / 12)
                    .offset(x: isDrawerOpen ? 20 : 215)
                , alignment: .topTrailing
            )
            
        }//: NAVIGATION
        .navigationViewStyle(.stack)
    }
    
    var controlGroup : some View {
        Group {
            HStack {
                //Scale Down
                Button {
                    closeDrawer()
                    withAnimation(.spring()) {
                        if imageScale > 1 {
                            imageScale -= 1
                            if imageScale == 1 {
                                resetImageState()
                            }
                        }
                    }
                } label: {
                    ControlImageView(icon: "minus.magnifyingglass")
                }

                //Reset
                Button {
                    closeDrawer()
                    withAnimation(.spring()) {
                        resetImageState()
                    }
                } label: {
                    ControlImageView(icon: "arrow.up.left.and.down.right.magnifyingglass")
                }
                
                //Scale Up
                Button {
                    closeDrawer()
                    withAnimation(.spring()) {
                        if imageScale < 5 {
                            imageScale += 1
                        }
                    }
                } label: {
                    ControlImageView(icon: "plus.magnifyingglass")
                }
            }
            .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .opacity(isAnimating ? 1 : 0)
        }//: CONTROLS
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
