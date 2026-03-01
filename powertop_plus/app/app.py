#!/usr/bin/env python3

import os
import sys
import argparse
from flask import Flask, render_template, send_file, jsonify
from datetime import datetime
import glob

app = Flask(__name__)

REPORTS_DIR = "/data/reports"

@app.route('/')
def index():
    """Main page showing latest report and report list"""
    reports = get_report_list()
    latest_report = get_latest_report()
    return render_template('index.html', reports=reports, latest_report=latest_report)

@app.route('/report/<filename>')
def view_report(filename):
    """View a specific PowerTop report"""
    # Security: prevent directory traversal
    if '..' in filename or filename.startswith('/'):
        return "Invalid filename", 400

    report_path = os.path.join(REPORTS_DIR, filename)

    # Check if file exists and is HTML
    if not filename.endswith('.html'):
        return "Invalid file type", 400

    if not os.path.exists(report_path):
        return f"Report not found: {filename}<br>Looking in: {REPORTS_DIR}<br>File exists: {os.path.exists(report_path)}", 404

    try:
        return send_file(report_path, mimetype='text/html')
    except Exception as e:
        return f"Error serving file: {str(e)}", 500

@app.route('/api/reports')
def api_reports():
    """API endpoint to get list of reports"""
    reports = get_report_list()
    return jsonify(reports)

@app.route('/api/status')
def api_status():
    """API endpoint to get addon status"""
    latest_report = get_latest_report()
    report_count = len(get_report_list())
    
    status = {
        'status': 'running',
        'latest_report': latest_report,
        'total_reports': report_count,
        'reports_directory': REPORTS_DIR
    }
    
    return jsonify(status)

def get_report_list():
    """Get list of available PowerTop reports"""
    reports = []
    if os.path.exists(REPORTS_DIR):
        pattern = os.path.join(REPORTS_DIR, "powertop_report_*.html")
        report_files = glob.glob(pattern)
        
        for report_file in sorted(report_files, reverse=True):
            filename = os.path.basename(report_file)
            timestamp_str = filename.replace("powertop_report_", "").replace(".html", "")
            
            try:
                timestamp = datetime.strptime(timestamp_str, "%Y%m%d_%H%M%S")
                reports.append({
                    'filename': filename,
                    'timestamp': timestamp.strftime("%Y-%m-%d %H:%M:%S"),
                    'size': os.path.getsize(report_file)
                })
            except ValueError:
                # Skip files that don't match expected format
                pass
    
    return reports

def get_latest_report():
    """Get information about the latest report"""
    latest_path = os.path.join(REPORTS_DIR, "latest.html")
    # Check if symlink exists and resolve it
    if os.path.islink(latest_path) or os.path.exists(latest_path):
        try:
            # Follow symlink to get actual file stats
            real_path = os.path.realpath(latest_path)
            if os.path.exists(real_path):
                stat = os.stat(real_path)
                return {
                    'exists': True,
                    'filename': 'latest.html',
                    'timestamp': datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d %H:%M:%S"),
                    'size': stat.st_size
                }
        except Exception as e:
            print(f"Error reading latest report: {e}")

    return {'exists': False}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='PowerTop Plus Web Interface')
    parser.add_argument('--port', type=int, default=8080, help='Port to run web server on')
    parser.add_argument('--host', default='0.0.0.0', help='Host to bind web server to')
    
    args = parser.parse_args()
    
    # Ensure reports directory exists
    os.makedirs(REPORTS_DIR, exist_ok=True)
    
    print(f"Starting PowerTop Plus web interface on {args.host}:{args.port}")
    app.run(host=args.host, port=args.port, debug=False)