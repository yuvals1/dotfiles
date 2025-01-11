#!/usr/bin/env bash
#
# Common logger functions for consistency.

log() {
    echo -e "${BLUE}📦 $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

success() {
    echo -e "${GREEN}✓ $1${NC}"
}

exists() {
    echo -e "${YELLOW}👌 $1${NC}"
}

