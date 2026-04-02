# StockUpdates
Real-time stock tracking iOS app showcasing scalable architecture and modern concurrency. Features live price updates for 25+ symbols using WebSocket integration, dynamic sorting (price &amp; change), and seamless cross-screen data synchronization. Includes symbol detail views with connection control, and with unit testing strategies for CI automation.

## Technology
SwiftUI

## 📈 Real-Time Stock Tracker iOS App

### 🚀 Overview

This project is a **real-time stock tracking iOS application** built to demonstrate modern iOS development practices, scalable architecture, and efficient data handling.

The app displays **live price updates for 25+ stock symbols** and ensures seamless synchronization across multiple screens using a simulated WebSocket-based data stream.


### 🎯 Objective

To build a high-performance iOS application that:

* Streams and displays real-time stock price updates
* Handles multiple symbols efficiently
* Demonstrates advanced architecture and concurrency patterns
* Maintains consistent state across different screens


### ✨ Core Features

#### 📊 Live Price Tracking

* Tracks **25+ stock symbols** (e.g., AAPL, GOOG, TSLA, AMZN, MSFT, NVDA)
* Real-time price updates with smooth UI refresh
* Efficient handling of frequent updates

#### 🔌 WebSocket Integration

* Uses `wss://ws.postman-echo.com/raw` for simulating real-time updates
* Random price generation sent and received via echo server
* Demonstrates real-time streaming architecture

#### 📋 Symbols List Screen

* Displays:

  * Symbol name
  * Current price
  * Price change indicator (↑ / ↓)
* Supports sorting:

  * By **Price**
  * By **Price Change**
* Tap on a symbol to view detailed information
* Shows **connection status** (Connected / Disconnected)
* Start/Stop button to control live updates

#### 📄 Symbol Details Screen

* Displays selected symbol details
* Real-time price updates synced with list screen
* Price change indicator
* Additional descriptive information


### 🧠 Architecture & Design

This project focuses on **clean, scalable, and maintainable architecture**, making it suitable for production-level apps.

* MVVM architecture following DDD Layers
* Reusable components and services
* Centralized state management for consistency across screens
* Designed to scale for:

  * High-frequency real-time data streams


### ⚡ Concurrency & Data Flow

* Uses modern concurrency techniques for handling real-time updates
* Efficient background processing for WebSocket events
* Thread-safe UI updates
* Ensures minimal latency and smooth scrolling even with frequent updates


### 🧪 Testing Strategy

A strong testing foundation is included to support CI/CD pipelines:

* **Unit Tests**

  * Business logic validation
  * Price update calculations
  * Sorting functionality

* **Scalable Test Design**

  * Easily extendable for integration and UI tests
  * Ready for CI automation pipelines
    

### 📦 Key Highlights

* Real-time data handling using WebSockets
* Advanced iOS architecture implementation
* Smooth and responsive UI with continuous updates
* Cross-screen state synchronization
* Production-ready code structure
* Testable and CI-friendly design
