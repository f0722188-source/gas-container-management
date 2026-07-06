.PHONY: help setup migrate run test clean

help:
	@echo "Gas Container Management - Available commands"
	@echo "setup       - Setup development environment"
	@echo "migrate     - Run database migrations"
	@echo "run         - Run development server"
	@echo "test        - Run tests"
	@echo "clean       - Clean up Python cache files"
	@echo "shell       - Open Django shell"
	@echo "docker-up   - Start Docker containers"
	@echo "docker-down - Stop Docker containers"

setup:
	python -m venv venv
	. venv/bin/activate && pip install -r requirements.txt
	cd backend && cp .env.example .env
	@echo "Setup complete! Run 'source venv/bin/activate' to activate the virtual environment"

migrate:
	cd backend && python manage.py migrate

run:
	cd backend && python manage.py runserver

test:
	cd backend && python manage.py test

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} +

shell:
	cd backend && python manage.py shell

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-logs:
	docker-compose logs -f web
