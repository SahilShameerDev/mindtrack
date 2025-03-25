from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
import logging
import datetime
import platform
import flask
import time

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load environment variables
load_dotenv()
API_KEY = os.getenv("GOOGLE_AI_API_KEY")

if not API_KEY:
    logger.warning("GOOGLE_AI_API_KEY not found in environment variables!")
    logger.warning("API will run in demo mode with generic responses")

# Initialize Google Gemini AI client only if we have an API key
genai = None
model = None

if API_KEY:
    try:
        import google.generativeai as genai
        
        # Updated API initialization - new method instead of configure()
        genai.configure(api_key=API_KEY)
        
        # Create the model with the correct API
        model = genai.GenerativeModel('gemini-1.5-flash')
        
        logger.info("Google Gemini AI client initialized successfully")
    except Exception as e:
        logger.error(f"Error initializing Google Gemini AI client: {e}")
        genai = None
        model = None

# Updated health check endpoint with more diagnostics
@app.route('/health', methods=['GET'])
def health_check():
    try:
        # Include more diagnostic info
        return jsonify({
            "status": "healthy",
            "ai_status": "active" if model else "disabled",
            "api_key_configured": bool(API_KEY),
            "timestamp": datetime.datetime.now().isoformat(),
            "server_info": {
                "platform": platform.system(),
                "python_version": platform.python_version(),
                "flask_version": flask.__version__
            }
        }), 200
    except Exception as e:
        logger.error(f"Error in health check: {e}")
        return jsonify({
            "status": "error",
            "error": str(e)
        }), 500

# Add timeout handling for the insights endpoint
@app.route('/get_mental_health_insights', methods=['POST'])
def get_mental_health_insights():
    try:
        # Get data from the request
        start_time = datetime.datetime.now()
        data = request.json
        logger.info(f"Received data: {data}")
        
        # Extract user data
        weekly_moods = data.get('weekly_moods', {})
        screen_time = data.get('screen_time', 'Unknown')
        unlock_count = data.get('unlock_count', 'Unknown')
        most_used_app = data.get('most_used_app', 'Unknown')
        mood_description = data.get('mood_description', 'Unknown')
        profession = data.get('profession', 'Unknown')
        gender = data.get('gender', 'Unknown')
        age = data.get('age', 'Unknown')
        
        # If model is not available, return demo response
        if not model:
            logger.warning("Using demo response since AI model is not available")
            insights = """
# Mental Health Insights

Based on your data, here are some personalized insights:

## Recognize Screen Time Patterns

Your daily screen time of {screen_time} suggests potential digital overload. 
Consider setting app time limits and taking regular breaks from your devices.

## Practice Mindfulness Techniques

Your mood patterns and unlock frequency indicate stress. Try deep breathing exercises 
or meditation for 5 minutes when you feel overwhelmed.

## Establish Healthy Phone Boundaries

With {unlock_count} phone unlocks daily, you might benefit from designating phone-free zones 
or times, particularly during meals and before bedtime.

## Seek Balance in Digital Life

Your most used app is {most_used_app}. Consider if this aligns with your priorities 
and values. Try diversifying your activities and interests.
""".format(screen_time=screen_time, unlock_count=unlock_count, most_used_app=most_used_app)
            
            # Shorter delay for demo mode
            time.sleep(1)
            
            processing_time = (datetime.datetime.now() - start_time).total_seconds()
            
            return jsonify({
                "success": True,
                "insights": insights,
                "mode": "demo",
                "processing_time_seconds": processing_time
            })
        
        # If we have a model, use Gemini AI
        # Prepare prompt for Gemini AI
        prompt = f"""
        As a mental health advisor, analyze the following data and provide 4-5 personalized mental health suggestions, explaining the rationale behind each suggestion:
        
        User Profile:
        - Age: {age}
        - Gender: {gender}
        - Profession: {profession}
        
        Weekly Mood Data: {weekly_moods}
        
        Digital Well-being Metrics:
        - Daily Screen Time: {screen_time}
        - Daily Phone Unlock Count: {unlock_count}
        - Most Used App: {most_used_app}
        
        User's Description of Their Mood: "{mood_description}"
        
        Based on this data, please provide:
        1. A brief analysis of potential mental health impacts
        2. 4-5 specific, actionable suggestions to improve mental wellbeing
        3. For each suggestion, explain why it might help this particular user
        
        Format each suggestion with a clear title and detailed explanation.
        """
        
        # Generate response from Google Gemini AI with updated API
        response = model.generate_content(prompt)
        insights = response.text
        logger.info(f"Generated insights successfully")
        
        # Log processing time
        processing_time = (datetime.datetime.now() - start_time).total_seconds()
        logger.info(f"Request processed in {processing_time:.2f} seconds")
        
        return jsonify({
            "success": True,
            "insights": insights,
            "mode": "ai",
            "processing_time_seconds": processing_time
        })
        
    except Exception as e:
        logger.error(f"Error generating mental health insights: {e}")
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

if __name__ == '__main__':
    # Binding to 0.0.0.0 instead of localhost allows connections from other devices
    app.run(host='0.0.0.0', port=5000, debug=True)
