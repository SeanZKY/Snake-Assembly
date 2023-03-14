;dmulti-segment executable file template.

data segment
start_question  db "press enter to start the game and esc to exit"
row db ?
column db ?
time_delay db ?
table_shapes_array db 0cdh,0bbh,0bah,0bch,0cdh,200,0bah,0C9h
table_print_times_array db 25,1,12,1,25,1,12,1
arena_color_question db "please choose a color for the arena$"
snake_color_question db "please choose a color for the snake$"
colors_array db 00010000b,00100000b,00110000b,01010000b,1001000b,01110000b,01100000b,0b
letter_color db ?
letter db ?
arena_color db 00000010b
snake_color db ?
loop_counter db 0
snake_size db 3
last_input db 64h
times_printed_pixel db 0
apple_pos dw ?
first_snake_pos dw ?
snake_pos_array dw 500 dup (0)
score db "Score:$"
high_score db "High Score:$"
high_score_array db 30h,30h,"$"
retry_question db "Do you want to retry?$"
bool_retry db 0              
easy db "easy"
medium db "medium"
hard db "hard"     
difficulty_first_pos EQU 7  
difficulty_pos_array db ?,?,?  
difficulty_array db 6,3,1 
opening_screen_row EQU 20
opening_screen_column EQU 20   
triangle_length db 50
triangle_width db 20          
first_column db ?    
instructions_string db "instructions:"
                    db " use w a s d to move, dont touch the border"
                    db   " or the snake's tail if u dont want to lose"
                    db " reach 99 to win ,there is a random color"  
                    db  " at the end of the  table$"
instructions_column EQU 20
instructions_row EQU 0   
instructions_color EQU 00000010b 
starting_screen_color EQU 8FH 
position_saver dw ?
snake_title db "" 

db "DBBBBBBBQBQBQBbv::rPBBBBBBBBBBBBBBQBQBQBBBBBBBQBBBq12BBBBBBBBBBBBBBBBBQBBBBBBBBB"
db "gQBBBBBBBBBBj        :BBBBBBBBBBBBBBBBBBBBBQBQBBBB   BBBBQBBBQBBBBBBBBBBBBBBBQBB"
db "DBBBQBQBBBBB  :BQBQ7  IBQB1SBBuv2BBBBBBBM5s5gBBBBB   BBBIvJBBBQ2rsgBBBQBQBBBBBBB"
db "gBBBBQBBBBBB   ugQBBBBBBBB        rBBBP       bBBB.  BB   XBB       EBBBBBBBBBBQ"
db "ZBBBBBBBBBQBBi       UBBBB   BBB   BQBi.rBQB   BBB.  K  XBBB   BBB:  BBBBBBBBBBB"
db "gBBBBBBQBBBBBBBBBgX.   BBB  YBBB:  BBBBI:  .  .BBB.     gBBQ         uBBBBBBBBBB"
db "DBBBBBBBBBBK  vBBBBB   BBB  iBBB.  BBB   BBB  .BBB.  BJ  2BB  .BBBQQXBBBBBBBBBQB"
db "gBBBBBBBBQBB    ...   qQBB  :BBB   BBB   ri    BBB   QB:  iQX  .jr   BBBBBBQBBBQ"
db "DBBBQBBBBBBBBgi    .uBBBBB::IBQBY:iBBBBi   dUiiBBBL:rBBBr:.BQBi   .PBBBBBBBBBBBB$"

arena_column db ?
arena_row db ?
pointer_counter db 0 
game_win db "you won!!!, press esc to exit$"












ends

stack segment
dw   128  dup(0)
ends

code segment
proc opening_screen;starting with the opening screen, here we ask the player if he wants to play or not enter if he does and escape if he doesn't which closes the game 
pusha;makes it more convenient to use


wait_for_enter:;here we are waiting for the user to hit enter to start we wont stop waiting until he hits enter or escape





xor bh, bh;clean it
mov bl, starting_screen_color;color
mov dh, opening_screen_row;makes it editable
mov dl, opening_screen_column;makes it editable
xor al, al;cleans it
mov cx, 45; size
lea bp, start_question;we want to ask the user
mov ah, 13h;and we need to print it to do so
int 10h

mov al,0
mov ah,1
int 16h;waiting for a key press


jz wait_for_enter;if there isn't any keypress just keep wautubg
mov ah,0
int 16h;if there is clean the buffer and check it
cmp al,0Dh;if enter exit loop and move on with the code
je screen_two
cmp al,1Bh;if escape close the game
je exit_game
jmp wait_for_enter;keep the loop alive even if the used did give us input just not the input we wanted
screen_two:

popa
ret
endp opening_screen

proc instructions;this porcedure job is to explain the player's the instruction, it appears only once when you open the game
    pusha 
    
   lea dx,instructions_string
   mov ah,9
    int 21h;prints the first part of the question,and prints it in different parts because we want enters in between to make it look better
   mov dh,10
   mov dl,0
   mov bh,0
   mov ah,2
   int 10h
   lea dx,snake_title
   mov ah,9
   int 21h 
    
    popa
    ret
endp instructions


proc draw_apple;this functions job is to generate a random number within a certain area (with limits) and to print an object (apple) there and also to print how many objects (apple) have the player touched (eaten) and save it after he lost as high score as long as he retries
pusha  
mov position_saver,si;saves for the apple check 
mov ah,13h
mov al,0
mov bh,0
mov bl,2
mov cx,6
mov dx,0
lea bp,score
int 10h;print the score     


mov cx,11
add dh,2
lea bp,high_score
int 10h



mov bh,0
mov dl,7
mov dh,0
mov ah,2
int 10h  ;set position






mov al,snake_size
sub al,3
mov bl,10
mov ah,0
div bl;takes the number of apples eaten (sub size by 3 because it starts in 3) and divides it to two digits in order to make it decimal

lea si,high_score_array

mov bl,[si]
inc si
mov bh,[si];moves to bx the high score
sub bl,30h
sub bh,30h
;here we check the tenths and if it's smaller the score is smaller if it's bigger the score is bigger if it's equal check units
cmp al,bl
jb score_not_higher;checks if the score tenths is smaller and if it is high score is bigger
cmp al,bl
ja score_higher;checks if the score tenth is bigger then the high score tenth and if it is high score is higher
cmp ah,bh
jbe score_not_higher;checks score untis and if it's bigger score is higher


score_higher:;here it puts in the high score array the updated version
jbe score_not_higher
mov [si],ah
add [si],30h
dec si
mov [si],al
add [si],30h




score_not_higher:

;here we print the score
mov dl,ah;here it saves the units
mov ah,9
mov bh,0
mov bl,2
mov cx,1
add al,30h;and here it prints the tenths
int 10h

mov al,dl;here it takes the save

mov bh,0
mov dl,8
mov dh,0
mov ah,2
int 10h;change position

mov ah,9
mov bh,0
mov bl,2
mov cx,1
add al,30h
int 10h;print the units
;here we print the high score
mov ah,13h
mov al,0
mov bh,0
mov bl,2
mov cx,2
mov dh,2
mov dl,12
lea bp,high_score_array;here it uses the array we save high score in and prints it
int 10h



new_random_column:;generates a random column within a certian range 
mov ah,2Ch
int 21h


mov al,dl
mov bl,2
mov ah,0
div bl;we div it by two
add al,15;and add 15

cmp al,64;because the range is 15-63
jae new_random_column;if it's out of range generate a new column until it's not out of range


;cmp al,column
;je new_random_column

mov bh,al;saves the column position


new_random_row:

mov ah,2Ch;generates a new random and again check if it's within it's range until it's within it's range then continue
int 21h 







mov al,dl
mov dl,bh
mov bl,5
mov ah,0
div bl;divs by 5
add al,4;add 4
cmp al,23;because range is 4-22
jae new_random_row
cmp al,row
je new_random_row
mov dh,al
 
 
 mov ah,snake_size
 mov cl,snake_size
cmp times_printed_pixel,ah;because we dont want it to go to negatvie but we do want to check it if the snake spawns on the apple (very very rare case) 
ja check_snake_size:
mov cl,times_printed_pixel
check_snake_size:


mov bx,first_snake_pos ;here we check if the apple landed on one of the snake slots just like we did in the game but with the snake's "head" and "body"
sub bx,200;goes to the first sanke position (to the first location of the first snake slot 
mov si,position_saver;now we got the position that we had before the procedure started
mov di,si
mov cl,snake_size;
mov ch,0 
is_snake_at_apple:

   

cmp di,bx;we check the first position of the snake to the current position and if it's equal or smaller we want to go to the opposide side of the position array we also do that when we save the position but opposite that why we had 200 places every time - every 100 slots we go back to the first slots we go back to the first position and overwrite the values until we again meet the limitation and when we check there is an option that it already restrated and the values that we need to check are the ones in the last slots and not the first ones
ja skip_reset
add di,200
skip_reset:
mov ax,[di];takes the position of the sanke
cmp ax,dx;check if it's equal to the apple  
je new_random_column;generate a new random for both column and row if it does
sub di,2;because we want to check every part of the snake body we start checking by the last position we got


loop is_snake_at_apple;continue checking for all of the snake's "body"

















inc snake_size;we increase it only in the end because we dont want to increase it if the apple spawned on the snake and also the first time that we call the function we dont want it to increase size so in other words it fits perfectly 

mov apple_pos,dx;we the new position to we can check if the snake had eaten the apple again   

mov bh,0
mov ah,2
int 10h ;we already got the position on dx so we just do the int and it goes to that position

mov ah,9  ;and in that position we print the apple
mov al,162;this looks cool
mov bh,0
mov bl,00000100b
mov cx,1
int 10h















popa   




ret
endp draw_apple





proc position_pointer;makes the code easier to write by just taking the variable we have and doing a position set without changing the registers values (pusha popa)
pusha
mov ah,2
mov dh,row
mov dl,column
int 10h
popa


ret
endp position_pointer

proc delay;very improtant: we need this procedure to make the snake run in a certain speed - to wait a few hundredth of second every time before printing the snake
pusha
mov ah,2Ch
int 21h
mov bl,dl;we do the clock int and take the hundredth of seconds and save them


check_until_equal:
mov ah,2Ch
int 21h;we do it again


sub dl,bl;we sub the first one by the second one 
cmp dl,time_delay; we check if the difference between them is smaller then the time we set it to wait
jb check_until_equal;if it is keep updating the clock until it does



popa
ret
endp delay


proc rectangle_arena;this procedure prints the arena using the array of lengths we set (and it also uses an array of values that match each one of these length for example: all of the corners have the same position as all of the 1's in the print time array


lea si,table_print_times_array
lea di,table_shapes_array

mov cx,[si];we start by using the print time array to check how many times to print by putting it's value in cx and then to a loop which prints one every time
mov ch,0

mov ah,9
mov bl,arena_color;then we set the color to the color that we saved for the table in the choose color procedure
mov bh,0



print_first_column:

call position_pointer;we set the position using the "shorcut" function that we have
inc column;the we first increase the column by one because we want to print the up slide
call table


loop print_first_column;does that for the times we wanted it to do

call print_corners;now it takes the print times and print it only one time
call table;here it takes the shape that we want to print

call print_corners;and here it takes the next value

dec column

print_first_row:;and just like the up slide it prints it the time we put in just now it goes one row down for each time and basicly it does all of that 2 times more just changes the position to go

inc row
call position_pointer
call table


loop print_first_row

call print_corners
call table



call print_corners
print_second_column:

dec column
call position_pointer
call table


loop print_second_column

call print_corners
call table

call print_corners

print_second_row:
dec row
call position_pointer
call table

loop print_second_row


call print_corners;and here we just print the last corner because we didn't print that in the start
call table








ret
endp rectangle_arena

proc table;also a "shortcut" procedure which takes the value in the position that we have in the shapes array (which is used for the value that we want to print) and prints it 
push cx;because we dont want to bothere the times of the loop

mov al,[di];takes it's value
mov cx,1;and prints it one time
mov ch,0

int 10h
pop cx



ret
endp table

proc print_corners;also a shortcut procedure this procedure is used to go to the next value in both arrays and also saves the value of the print time array in cx which we will use for loops
inc di
inc si
mov cx,[si];
mov ch,0

ret
endp print_corners




proc choose_color

add column,2;because our starting position is at the upper left side (corner) of the triangle we want it to go a bit to the right and down so we wont print on it
add row,2   
mov ah,row
mov al,column      
mov arena_row,ah
mov arena_column,al

mov dh,1
mov dl,20;the position of the color picking question
mov ah,2
int 10h

lea dx,arena_color_question;the arena color question
mov ah,9
int 21h




lea si,colors_array;all of the colors in an array in the order that they appear in the screen so we wont have to compare each one of time (which turs to be a total of 8 times) 

call position_pointer;set the position

mov dl,9;because we want to do it 8 times and it start by removing one
print_all_colors:


mov cx,2;-for every row
make_more_pixels:

push cx;save the conter

mov ah,9
mov al,0
mov bh,0
mov bl,[si];prints the color we want
cmp bl,0
jne not_speciel_case
mov bl,15
mov al,63
not_speciel_case:
mov cx,3;three times - (to make it look better)
int 10h

inc row;now do the same for the row below
call position_pointer;set the position

pop cx

loop make_more_pixels



cmp dl,6;
je go_new_line;if it does go to a new line



sub row,2;because we added two rows when we printed the color
add column,6;enough distance to print the new color
call position_pointer;set position
jmp dont_go_new_line;dont go to a new line

go_new_line:;go to a new line:
mov al,arena_column
mov column,al;first printing position
add row,3;go line donwn
call position_pointer ;set positon

dont_go_new_line:


dec dl
mov cl,dl 
inc si



loop print_all_colors

inc arena_column 
add arena_row,2


color_choose_from_table:;now we choosed printing the color and we are letting the user pick the colors
mov al,arena_column
mov ah,arena_row
mov column,al
mov row,ah
call position_pointer;the middle position of the first color

mov letter,18h;a sign from the ascii table that looks like an upper arrow which I thought suits what I want it to look like
mov letter_color,00001111b;the color I wanted
call print_in_color;just like the position pointer it's a shortcut


choose_color_from_table:
mov ah,1
int 16h;wait for key input
jnz key_pressed
jmp choose_color_from_table;keep lopping until got key input


key_pressed:
mov ah,0
int 16h;clean buffer
cmp al,64h
je go_right;compare to d if it is go to go_right
cmp al,61h
je go_left;compare to a if it is go to go_left
cmp al,0Dh
je color_picked;compare to enter if it is go to color_picked
jmp choose_color_from_table;if it's none of thos just keep lopping until u get correct input


go_left:
cmp pointer_counter,4;if it's the pointer is on the most left column go to the maybe line up
je maybe_line_up 
cmp pointer_counter,0
je choose_color_from_table

dec pointer_counter
mov letter,0;if it's not start off by delteing the "cursor"
call print_in_color
sub column,6;and go "left"
call position_pointer
mov letter,18h;and print it in the new position
call print_in_color
jmp choose_color_from_table;now keep lopping until the user clicks enter

go_right:
cmp pointer_counter,3;if it's on the most right column go to maybe line down
je maybe_line_down 
cmp pointer_counter,7
je choose_color_from_table
 
inc pointer_counter
mov letter,0;just like the go_left here it deletes it last position print it in the new position go back to loop until the user press enter
call print_in_color
add column,6
call position_pointer
mov letter,18h
call print_in_color
jmp choose_color_from_table




maybe_line_down:
mov al,arena_column
mov ah,arena_row

inc pointer_counter
mov letter,0;and if it is
call print_in_color;delete last cursor
add row,5;go row down
mov column,al;go to the first color
call position_pointer
mov letter,18h
call print_in_color;print new one in the new position
jmp choose_color_from_table;wait for enter

maybe_line_up:
mov al,arena_column
mov ah,arena_row
add al,18
dec pointer_counter
mov letter,0;if it is just delete the old one and print a new one at the first column at the upper row then keep lopping until enter
call print_in_color
sub row,5
mov column,al
call position_pointer
mov letter,18h
call print_in_color
jmp choose_color_from_table






;row -  9,14
;column - 27,33,39 45






color_picked:
call snake_and_table_color
mov snake_color,dl;here we put the color in the snake_color
mov pointer_counter,0
cmp loop_counter,1;here we check if it's the first time that we did all of this (we want to this exacly two time because we want one time for the snake color and one time for the arena color)
je finish_color_pick;if is end function so that in the second loop the color will be given to the snake and in the first one to the arena because we put them both in the snake just that in first one we also put in the arena and in the second one it's value is overwritten so that we get what we want !

mov loop_counter,1;if it's the first time we did all of that mark that as the first time so that next time we will know that it's the second time (as sam our teacher used to say smart people start counting at zero)
mov arena_color,dl;just as I explained earlier now we got the first color in the snake arena and the second time it will only go to the snake
mov letter,0
call print_in_color;here we delete the cursor for the next loop
mov column,20
mov row,1
call position_pointer

mov cx,40
mov ah,9
mov bl,00001111b
mov bh,0
mov al,0
int 10h  ;and delete the question


lea dx,snake_color_question
mov ah,9
int 21h     ;and print the new one 
;
jmp color_choose_from_table:;and the fun continues! in the second loop...




finish_color_pick:






ret
endp choose_color

proc print_in_color; a shorcut takes the letter that we want to print and the color that we want to print it in and prints it while not changing any register values (pusha popa)
pusha
mov ah,9
mov bh,0
mov bl,letter_color
mov al,letter
mov cx,1
int 10h
popa
ret
endp print_in_color

proc snake_and_table_color
lea si,colors_array;takes the color array
mov bx,si
add bl,pointer_counter
mov dl,[bx]            
cmp dl,0
jne not_random
mov ah,2Ch
int 21h
mov al,dl
mov ah,0
mov bl,16
div bl
mov pointer_counter,al   
call snake_and_table_color

not_random:

ret
endp snake_and_table_color      

proc choose_difficulty ;this procedure is responsible for letting the user choose the difficulty (including printing the options)
    pusha     
    mov ah, 0
    mov al, 3
    int 10h;clean screen  
    
    mov ah,13h
    mov al,0
    mov bh,0
    mov bl,15
    mov cx,4
    mov dh,3
    mov dl,12
    lea bp,easy
    int 10h;prints the easy option  
    
    lea si,difficulty_pos_array;saves it's value so we may use it for the "pointer" later
    mov [si],dl
    add [si],2 ;and we want it the pointer to be in the middle of the word
    inc si;so we may move on to the next value
    
    add dl,20;the space we want between them
    lea bp,medium
    mov cx,6
    int 10h ;prints medium
    mov [si],dl
    add [si],3;saves it and adds to it because we want the pointer to be in the middle of the word
    inc si;so we may move on to the next value
    add dl,23;the space that we want between them
    mov cx,4
    lea bp,hard
    int 10h;prints hard
    mov [si],dl;and again
    add [si],2
    sub si,2;go to the first position we saved 
    
     
    inc dh;because we want it one row under
    mov bh,0
    mov bl,00000100b
    mov cx,1
   
    
    
       
    mov di,si;first position adress
    
    ;7
    
    
    check_until_choose:  
    mov dl,[si]
    mov bl,0
    mov al,18h 
    mov ah,2
    int 10h;position set (every time)   
    
    mov bl,00000100b
    mov ah,9
    int 10h;prints pointer (every time) 
    
    mov ah,1
    int 16h
    jz check_until_choose;check if there is any value if not loop 
    mov ah,0  ;clean buffer
    int 16h   
    
    cmp al,64h    
    jne dont_go_right;if it's not d check if it's a
    add di,2
    cmp si,di;check if si is already on the right edge  
    je fix_variable;if it is go to fix_variable
    sub di,2 ;if it's not also reset di
    mov bl,0 
    mov ah,9
    int 10h;deletes last pointer position    
    inc si;go to the next position      
    jmp check_until_choose
    
    dont_go_right:;if it's not right check if it's left
    cmp al,61h 
    jne dont_go_left;if it's not left go to dont_go_left
       
     
     cmp si,di;checks if it's position equal to the left edge position
    
    je check_until_choose;if it is loop   
    mov bl,0   
    mov ah,9
    int 10h;deletes it's last position
    dec si; go to the position before
    jmp check_until_choose
    
    fix_variable:
    sub di,2;reset di's value    
    jmp check_until_choose;keep lopping
    
    
    dont_go_left:;check's if it's enter
    cmp al,0Dh;if it's not enter keep lopping
    jne check_until_choose
    sub si,di;now we can see the difference between them (0-2)
    lea di,difficulty_array
    add di,si;and through this calculation we now have access to the value that we need for the snake
    mov al,[di]
    mov time_delay,al;and we set the time delay as the value we inserted 
    
    
    
    
    popa
    
    ret
endp difficulty










proc snake_func;this procedure is responbile for running the acctual game now that we got all the user input that we needed (printing and deleting the snake and checking if it failed)



add column,20;the position we want it to start
add row,15
mov dx,1
lea si,snake_pos_array;we want it int order to check the position of the snake
mov first_snake_pos,si;the adress of the first position                              
add first_snake_pos,198;the adress of the last position

call draw_apple;note do that the apple wont spawn on the snake
game_run:

mov cx,2607h
mov ah,1
int 10h;dont show cursor 













add row,dh
add column,dl;sets new position after checking movment (could also be a negative number)

call position_pointer;set position

call delay;delay for the snake movment

mov ah,9
mov al,0
mov bh,0
mov bl,snake_color
mov cx,1
int 10h;prints a block by block (so we can do the turn and it works better)






cmp si,first_snake_pos;we check if is the last position in the array (because we dont want it to go out of range)
jbe no_need_to_reset;if it's not continue
sub si,200;if it is go to the first place



no_need_to_reset:

mov bh,row
mov bl,column
mov [si],bx;puts the position in the array




dec arena_column
cmp bl,arena_column ;checks if the snake is out of the arena boundaries 
je end_snake
mov ah,triangle_length
mov al,triangle_width
add arena_column,ah
cmp bl,arena_column
je end_snake
cmp bh,arena_row
je end_snake    
add arena_row,al
cmp bh,arena_row
je end_snake    
sub arena_column,ah
sub arena_row,al     
inc arena_column

cmp bx,apple_pos;checks if the position of the snake's head is equal to the position of the apple

jne snake_not_eat;if it's not continue



call draw_apple;if it is delete the apple and create a new one

snake_not_eat:
mov bx,0










mov ah,snake_size
cmp times_printed_pixel,ah;because we dont want to delete pixels or check it the snake touches itself if the game only just begun (for the first few pixels which are worth to the snake size)

jb dont_delete_pixel











mov cl,snake_size;we put the snake size
mov ch,0
mov di,si;we use the di as a replacement in order to not change si
mov ax,[si]
sub first_snake_pos,200 ;the first adress of the array
is_movment_error1:

sub di,2
cmp di,first_snake_pos;we check if the array is  in it's first adress and if it is go to the last adress
ja no_reset_loop1

add di,200;go to the last

no_reset_loop1:
mov bx,[di]
cmp ax,bx;we compare the snake's previous locations to the now location and it's worth go to end_snake
je end_snake
loop is_movment_error1;we loop it the number of snake size times








mov dx,[di];the last tail position








mov ah,2



mov bh,0
int 10h;position set

cmp time_delay,6
jb no_need_to_slow;only if it's above there is a need to make the animation more smooth because of the gap between the time deleting a "square" to printing it
mov al,time_delay
mov ah,0
mov bl,3
div bl;calculations to see just how much we want the time delay to be
mov bh,time_delay;save
mov time_delay,al   
call delay       
mov time_delay,bh;so it wont change

no_need_to_slow:

mov ah,9
mov al,0
mov bh,0
mov bl,0
mov cx,1
int 10h ;delete it


add first_snake_pos,200;reset it



dont_delete_pixel:

cmp times_printed_pixel,100 ;to not take too much space
je dont_add_to_count
inc times_printed_pixel
dont_add_to_count:









mov dx,0


mov ah,1
int 16h;check for input
jz dont_clean_buffer;if no input keep lopping
mov ah,0
int 16h;if user input, clean buffer

dont_clean_buffer:
jmp skip_wrong_input;we skip it naturally

wrong_input:
mov al,last_input;so it continue the last way it went even if the user didn't input (and start by going right)

skip_wrong_input:

cmp al,64h
je snake_go_right;if it's d go to snake_go_right

cmp al,61h
je snake_go_left;if it's a go to snake_go_left

cmp al,77h
je snake_go_up; if it's w go to snake_go_up

cmp al,73h
je snake_go_down;if it's s go to snake_go_down

jmp wrong_input;if it's neither of them give it the last input and continue as usuall




snake_go_right:

cmp last_input,61h;uses the last input the check if the direction are upside and if it is do noting
je wrong_input
inc dl;in othere words go one right
jmp skip_other_inputs

snake_go_left:

cmp last_input,64h;do it the same here and all the other places
je wrong_input
dec dl;go one left
jmp skip_other_inputs

snake_go_up:

cmp last_input,73h
je wrong_input
dec dh;go one up
jmp skip_other_inputs




snake_go_down:

cmp last_input,77h
je wrong_input
inc dh;go one up

skip_other_inputs:


mov last_input,al;update it's value



mov cx,2








add si,2;go to the next adress

cmp snake_size,90;end the game
jae won




loop game_run





;pink
end_snake:

ret
endp snake_func     

proc triangle_size;works with the size array to put the sizes we want after we call the funcion and put the values we want in slides
    pusha   
    lea si,table_print_times_array
    mov al,triangle_length 
    mov ah,triangle_width 
    
    mov cx,2
    fill_print_time_array:

    mov [si],al;fills it
    add si,2; skips one because for every one of them there will be a number that represenst the corners after
    mov [si],ah
    add si,2;go to the next and skips one
    loop fill_print_time_array;do it two time because there are 4 slides 
    
    popa
    ret
endp triangle_size











start:
; set segment registers:
mov ax, data
mov ds, ax
mov es, ax

; add your code here

mov ah, 0
mov al, 3
int 10h  ;clean screen 


call instructions;explain instructions
call opening_screen;checks if the user want to play 
   
start_the_game:

mov ah, 0;clear screen every retry
mov al, 3
int 10h

 
cmp bool_retry,1;if it's already retry dont let the user pick colors/difficulty
je skip_choose_color

mov row,10  ;the place we want to print the color table
mov column,10
mov triangle_length,25
mov triangle_width,12;responsible for the slides length
call triangle_size;puts them in the array responsible for creating them
call rectangle_arena ;create arena

mov ah,column
mov first_column,ah;use it in the code
call choose_color;so the user can choose color  
call choose_difficulty;so the user can choose difficulty 


skip_choose_color:
mov ah,0
mov al,3
int 10h;clean screen

mov row,3
mov column,15;the place we want to print the arena
mov ah,row
mov al,column      
mov arena_row,ah
mov arena_column,al




mov triangle_length,50
mov triangle_width,20;repsonsible for the size
call triangle_size;puts size in array
call rectangle_arena;calls arena



call snake_func;start the game

is_retry:   


add first_snake_pos,10

mov ah,0
mov al,3
int 10h;clean screen

mov dl,0
mov dh,0
mov ah,13h
mov al,0
mov bh,0
mov cx,21
mov bl,15
lea bp,retry_question
int 10h;asks if the user want to coninte



mov ah,7
int 21h;asks for input

cmp al,0Dh
je retry;if enter retry

cmp al,1bh
je exit_game;if escape close game  




mov bool_retry,0
jmp is_retry;if neither keep asking






retry:

mov bool_retry,1 ;resets all value important that we changed
mov snake_size,3;snake zide
mov last_input,64h;last input
mov times_printed_pixel,0;time printed pixel

jmp start_the_game;and start the game
































mov ah,7; stop!!!!!!
int 21h

; wait for any key....
mov ah, 1
int 21h
won:
mov ah, 0
mov al, 3
int 10h

lea dx,game_win
mov ah,9
int 21h          
wait_to_exit:
mov ah,7
int 21h
cmp al,1bh
je exit_game
jmp wait_to_exit     


exit_game:
mov ax, 4c00h ; exit to operating system.
int 21h
ends

end start ; set entry point and stop the assembler.


; [SOURCE]: C:\Users\seanr\Downloads\snake project.asm