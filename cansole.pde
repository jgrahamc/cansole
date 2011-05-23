// Cansole - video game console in a can
//
// Copyright (c) 2011 John Graham-Cumming
//
// Plays PONG

#include "TVout.h"
#include "fontALL.h"

TVout TV;

// This gives the location of the ball and the speed
// with which the ball is moving in the X and Y directions

int ball_x, ball_y;
int delta_x, delta_y;

// The input A/D ports on which the two paddles are connected

int left_paddle = 5;
int right_paddle = 2;

// The speed with which the paddles are moving.  Set by draw_paddles.
// The other two values are used to store the last paddle position for
// calculating the speed.

int left_paddle_speed, right_paddle_speed;
int left_paddle_y, right_paddle_y;

// The scores for the two players

int left_score, right_score;

// 1 if the game is being played, 0 if waiting for the game to start

int game_running;

// The speed the ball is moving at when it starts

int ball_speed;

void setup() {
  TV.begin(_PAL);
  TV.select_font(font6x8);
   
  center_text(0, "Cansole v0.1 - PONG" );
  center_text(4, "Press Fire to play" );
  
  while ( !fire_pressed() ) {
  }
   
  reset_game();
}

// reset_ball: reset the ball to the center of the court for a serve

void reset_ball()
{
  ball_x = 64;
  ball_y = 48;
  delta_x = ball_speed;
  delta_y = ball_speed;
}

// reset_game: start a new game running

void reset_game() 
{
  left_score = 0;
  right_score = 0;
  game_running = 1;
  ball_speed = 1;
  left_paddle_y = -1;
  right_paddle_y = -1;
  
  reset_ball();
}

void loop() {
  TV.delay(50);

  if ( !game_running ) {
    TV.clear_screen();
    if ( right_score > left_score ) {
      center_text( 0, "Blue wins!" );
    } else {
      center_text( 0, "Red wins!" );
    }
    
    center_text( 6, "Game over" );
    center_text( 8, "Press Fire to play again" );
    
    if ( fire_pressed() ) {
      game_running = 1;
    }
    
    return;
  }
  
  TV.clear_screen();
  char buffer[32];
  sprintf( buffer, "%d %d", left_score, right_score );
  center_text(0,buffer);
  
  draw_paddles();
  
  // This moves the ball
  
  ball_x += delta_x;
  ball_y += delta_y;

  // Handle the ball hitting the left or right paddle.  When hit the x velocity
  // is reversed and the velocity updated based on the speed with which the
  // paddle was moving at the time of the hit
  
  if ( ( ball_x <= 2 ) && ( TV.get_pixel( 1, ball_y ) == WHITE ) ) {
    delta_x = -delta_x;
    delta_x += left_paddle_speed;
    delta_y += left_paddle_speed;
    ball_x = 2;
  }
  
  if ( ( ball_x >= 125 ) && ( TV.get_pixel( 126, ball_y ) == WHITE ) ) {
    delta_x = -delta_x;
    delta_x += right_paddle_speed;
    delta_y += right_paddle_speed;
    ball_x = 125; 
  }
  
  // Handle a bounce off the top of bottom of the play area
  if ( ball_y <= 16 ) {
    delta_y = -delta_y;
    ball_y = 16;
  }
  
  if ( ball_y >= 95 ) {
    delta_y = -delta_y;
    ball_y = 95;
  }  
    
  // Handle the ball going off the left or right hand side of the screen.  Scores
  // are updated and first player to 10 wins
  
  if ( ball_x < 1 ) {      
    reset_ball();
    right_score += 1;
    if ( right_score == 10 ) {
      game_running = 0;
      return;
    }
  }
  
  if ( ball_x > 127 ) {
    reset_ball();
    left_score += 1;
    if ( left_score == 10 ) {
      game_running = 0;
      return;
    }
  }

  TV.set_pixel(ball_x, ball_y,WHITE);
}

// get_paddle: get the paddle position by reading the A/D converter and
// scaling to the available y positions

int get_paddle( int p ) 
{
  int pos = (long)analogRead(p)*64/1023;
  pos += 16;
  return pos;
}

// draw_paddles: draw the two paddles and calculate paddle velocity

void draw_paddles()
{
  int left = get_paddle( left_paddle );
  int right = get_paddle( right_paddle );
  
  TV.draw_column(0,left,left+15,WHITE);
  TV.draw_column(1,left,left+15,WHITE);
  TV.draw_column(126,right,right+15,WHITE);
  TV.draw_column(127,right,right+15,WHITE);
  
  if ( left_paddle_y != -1 ) {
    left_paddle_speed = left - left_paddle_y;
    if ( left_paddle_speed < -4 ) {
      left_paddle_speed = -4;      
    }
    if ( left_paddle_speed > 4 ) {
      left_paddle_speed = 4;      
    }
  }
  left_paddle_y = left;

  if ( right_paddle_y != -1 ) {
    right_paddle_speed = right - right_paddle_y;
    if ( right_paddle_speed < -4 ) {
      right_paddle_speed = -4;      
    }
    if ( right_paddle_speed > 4 ) {
      right_paddle_speed = 4;      
    }
  }
  right_paddle_y = right;

}

// center_text: print a line of text centered on the screen at row y (in lines of
// text not pixels; text is 8 pixels high)

void center_text( int y, char * t ) 
{
  int l = strlen(t) * 6;
  l = (128 - l)/2;
  TV.println( l, y*8, t );
}

// fire_pressed: determine if the fire button is being pressed

int fire_pressed() 
{
  return !digitalRead(2); 
}

