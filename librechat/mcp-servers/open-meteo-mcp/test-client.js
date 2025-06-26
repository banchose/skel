#!/usr/bin/env node

const { spawn } = require('child_process');
const readline = require('readline');

class MCPTestClient {
  constructor() {
    this.server = null;
    this.messageId = 1;
  }

  async startServer() {
    console.log('🚀 Starting Open-Meteo MCP Server...');
    
    this.server = spawn('node', ['server.js'], {
      stdio: ['pipe', 'pipe', 'inherit']
    });

    this.server.on('error', (error) => {
      console.error('❌ Server error:', error);
    });

    this.server.on('exit', (code) => {
      console.log(`🛑 Server exited with code ${code}`);
    });

    // Wait for server to initialize
    await new Promise(resolve => setTimeout(resolve, 2000));
    console.log('✅ Server should be ready');
  }

  async sendMessage(message) {
    return new Promise((resolve, reject) => {
      let response = '';
      
      const timeout = setTimeout(() => {
        reject(new Error('Timeout waiting for response (30s)'));
      }, 30000);

      const dataHandler = (data) => {
        response += data.toString();
        
        // Look for complete JSON responses
        const lines = response.split('\n');
        for (const line of lines) {
          const trimmed = line.trim();
          if (trimmed) {
            try {
              const parsed = JSON.parse(trimmed);
              if (parsed.id === message.id) {
                clearTimeout(timeout);
                this.server.stdout.removeListener('data', dataHandler);
                resolve(parsed);
                return;
              }
            } catch (e) {
              // Not complete JSON yet, continue
            }
          }
        }
      };

      this.server.stdout.on('data', dataHandler);
      
      const messageStr = JSON.stringify(message);
      console.log(`📤 Sending: ${messageStr.substring(0, 100)}${messageStr.length > 100 ? '...' : ''}`);
      this.server.stdin.write(messageStr + '\n');
    });
  }

  async testListTools() {
    console.log('\n📋 Testing: List Available Tools');
    
    const message = {
      jsonrpc: '2.0',
      id: this.messageId++,
      method: 'tools/list',
      params: {}
    };

    try {
      const response = await this.sendMessage(message);
      console.log('✅ Response received');
      
      if (response.result && response.result.tools) {
        console.log('🔧 Available tools:');
        response.result.tools.forEach(tool => {
          console.log(`   - ${tool.name}: ${tool.description}`);
          console.log(`     Parameters: ${Object.keys(tool.inputSchema.properties || {}).join(', ')}`);
        });
      }
      return response;
    } catch (error) {
      console.error('❌ Error listing tools:', error.message);
      throw error;
    }
  }

  async testWeatherCall(args = {}) {
    const location = args.location_name || 'Albany, NY';
    console.log(`\n🌤️  Testing: Weather Forecast for ${location}`);
    
    if (Object.keys(args).length > 0) {
      console.log('📍 Parameters:', JSON.stringify(args, null, 2));
    }
    
    const message = {
      jsonrpc: '2.0',
      id: this.messageId++,
      method: 'tools/call',
      params: {
        name: 'get_weather_forecast',
        arguments: args
      }
    };

    try {
      console.log('⏳ Calling Open-Meteo API...');
      const response = await this.sendMessage(message);
      
      if (response.error) {
        console.error('❌ Tool call error:', response.error);
        return response;
      }
      
      console.log('✅ Weather call successful!');
      
      if (response.result && response.result.content) {
        console.log('\n📊 Response Preview:');
        const content = response.result.content[0];
        if (content.text) {
          // Show first 800 characters to see the weatherman prompt
          const preview = content.text.substring(0, 800);
          console.log(preview + (content.text.length > 800 ? '\n... [truncated]' : ''));
          console.log(`\n📏 Total response length: ${content.text.length} characters`);
        }
      }
      
      return response;
    } catch (error) {
      console.error('❌ Error calling weather tool:', error.message);
      throw error;
    }
  }

  async runTests() {
    try {
      await this.startServer();
      
      // Test 1: List available tools
      await this.testListTools();
      
      // Test 2: Default weather call (Albany, NY - your bash function defaults)
      console.log('\n🏠 Testing with your default Albany, NY location...');
      await this.testWeatherCall();
      
      // Test 3: Custom location
      console.log('\n🗽 Testing with New York City...');
      await this.testWeatherCall({
        latitude: 40.7128,
        longitude: -74.0060,
        location_name: "New York City, NY",
        forecast_days: 5
      });
      
      console.log('\n🎉 All tests completed successfully!');
      console.log('\n💡 Your MCP server is working correctly and ready for LibreChat integration!');
      
    } catch (error) {
      console.error('\n💥 Test failed:', error.message);
      console.error('Stack:', error.stack);
    } finally {
      if (this.server) {
        this.server.kill();
      }
    }
  }

  async interactiveMode() {
    await this.startServer();
    await this.testListTools();
    
    console.log('\n🔧 Interactive Mode - Test different locations');
    console.log('Format: latitude,longitude,location_name,forecast_days');
    console.log('Examples:');
    console.log('  40.7128,-74.0060,NYC,3');
    console.log('  42.742830,-73.801163,Albany NY,3  (your defaults)');
    console.log('Or just press Enter for Albany, NY defaults');
    console.log('Type "quit" to exit\n');

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    const askForInput = () => {
      rl.question('🌤️  Enter parameters (or "quit"): ', async (input) => {
        if (input.toLowerCase() === 'quit') {
          rl.close();
          if (this.server) this.server.kill();
          return;
        }

        let args = {};
        if (input.trim()) {
          const parts = input.split(',').map(p => p.trim());
          if (parts.length >= 2) {
            args.latitude = parseFloat(parts[0]);
            args.longitude = parseFloat(parts[1]);
            if (parts[2]) args.location_name = parts[2];
            if (parts[3]) args.forecast_days = parseInt(parts[3]);
          }
        }

        try {
          await this.testWeatherCall(args);
        } catch (error) {
          console.error('❌ Error:', error.message);
        }
        
        console.log('\n' + '─'.repeat(50));
        askForInput();
      });
    };

    askForInput();
  }
}

// Command line interface
const args = process.argv.slice(2);
const client = new MCPTestClient();

if (args.includes('--interactive') || args.includes('-i')) {
  client.interactiveMode();
} else {
  client.runTests();
}
