function StroopFnB(varargin)

prompt={'SUBJECT ID'};
defAns={'4444'};

answer=inputdlg(prompt,'Please input subject info',1,defAns);

ID=str2double(answer{1});
% COND = str2double(answer{2});
% SESS = str2double(answer{3});
% prac = str2double(answer{4});


%rng(ID); %Seed random number generator with subject ID
d = clock;


KbName('UnifyKeyNames');
  
KEY = struct;
KEY.rt = KbName('SPACE');

COLORS = struct;
COLORS.WHITE = [255 255 255];
COLORS.RED = [255 0 0];
COLORS.BLUE = [0 0 255];
COLORS.GREEN = [0 255 0];
wcolor = [COLORS.WHITE; COLORS.RED; COLORS.BLUE; COLORS.GREEN];

STIM = struct;
STIM.rows = 10;
STIM.cols = 10;
STIM.totes = STIM.rows*STIM.cols;
STIM.blocks = 1;
STIM.trials = 2;

%For saving later...
[mdir,~,~] = fileparts(which('StroopFnB.m'));
        
commandwindow
%% Word

try
    load('stim_text.mat')
catch
    try
        cd(mdir);
        load('stim_text.mat')
    catch
        error('Cannot load stim_text file. Please be sure stim_text.mat is saved in the same directory as StroopFnB.m (this task''s file).')
    end
end

%Choose condition, word list, & color list;
cond = randperm(2);  %1 = exp first, 2 = control first.
word_cond = randi(4,2,1);      %randomly select one of four word lists from exp & control groups; # can repeat
color_cond = randperm(4,2);     %randomly select one of four color lists; sample without replacement!

Stroop = struct('ID',ID,'Date',sprintf('%s %2.0f:%02.0f',date,d(4),d(5)),'Condition',cond,'Word_List',word_cond,'Color_List',color_cond);


%%
%change this to 0 to fill whole screen
DEBUG=0;

%set up the screen and dimensions

%list all the screens, then just pick the last one in the list (if you have
%only 1 monitor, then it just chooses that one)
Screen('Preference', 'SkipSyncTests', 1);

screenNumber=max(Screen('Screens'));

if DEBUG==1;
    %create a rect for the screen
    winRect=[0 0 640 480];
    %establish the center points
    XCENTER=320;
    YCENTER=240;
else
    %change screen resolution
%     Screen('Resolution',0,1024,768,[],32);
    
    %this gives the x and y dimensions of our screen, in pixels.
    [swidth, sheight] = Screen('WindowSize', screenNumber);
    XCENTER=fix(swidth/2);
    YCENTER=fix(sheight/2);
    %when you leave winRect blank, it just fills the whole screen
    winRect=[];
end

%open a window on that monitor. 32 refers to 32 bit color depth (millions of
%colors), winRect will either be a 1024x768 box, or the whole screen. The
%function returns a window "w", and a rect that represents the whole
%screen. 
[w, wRect]=Screen('OpenWindow', screenNumber, 0,winRect,32,2);

%%
%you can set the font sizes and styles here
Screen('TextFont', w, 'Arial');
%Screen('TextStyle', w, 1);
Screen('TextSize',w,25);

%% Instructions!
DrawFormattedText(w,'This is a test of how fast you can name the font color for the printed words. After pressing the start button, you are to go down the columns starting with the first one until you complete it and then continue without stopping down the remaining columns in order.  You will state aloud, the font color of the words.  If you make a mistake, correct your error and continue without stopping.\n\nAgain, you will name the font color as quickly and as accurately as possible ignoring the actual word typed.  When you have finished all columns press the space bar.\n\nPress any key to continue.','center','center',COLORS.WHITE,60,[],[],1.5);
Screen('Flip',w);
KbWait([],2);

DrawFormattedText(w,'The task will begin now. Remember, name the COLOR of the font as quickly as you can. When you are finished, press the space bar.\n\nPress any key to begin the task.','center','center',COLORS.WHITE,60,[],[],1.5);
Screen('Flip',w);
KbWait([],2);

%%
%you can set the font sizes and styles here
Screen('TextFont', w, 'Arial');
%Screen('TextStyle', w, 1);
Screen('TextSize',w,17);
 
%figure out distance between words on present screen
vert_loc = fix(wRect(4)/STIM.rows);
horz_loc = fix(wRect(3)/STIM.cols);

%produce equal intervals for word placement across vertical and horizontal
%dimensions.
wloc_vert = 35:vert_loc:vert_loc*STIM.rows;
wloc_horz = 20:horz_loc:horz_loc*STIM.cols;


for trial = 1:STIM.trials;
    wordlist = stim_text{Stroop.Word_List(trial),Stroop.Condition(trial)};
    colorlist = stim_text{Stroop.Color_List(trial),3};
    
    
    for x = 1:STIM.cols;
        for y = 1:STIM.rows;
            wcounter = (x-1)*STIM.rows + y;
            dat_word = wordlist{wcounter};
            %CenterTextOnPoint(w,dat_word,wloc_horz(x),wloc_vert(y),wcolor(colorlist(wcounter),:));
            DrawFormattedText(w,dat_word,wloc_horz(x),wloc_vert(y),wcolor(colorlist(wcounter),:),10);
        end
    end
    
    rt_start = Screen('Flip',w,[],1);
    
    FlushEvents();
    
    while 1
        Screen('Flip',w,[],1);
        
        [down, ~, code] = KbCheck();
        
        if down ==1 && any(find(code) == KEY.rt);
            Stroop.rt(trial) = GetSecs() - rt_start;
            break
        end
    end
    
    if trial < STIM.trials;
        Screen('Flip',w);
        DrawFormattedText(w,'Press any key to begin the next round.','center','center',COLORS.WHITE);
        Screen('Flip',w);
        KbWait([],2);
        Screen('Flip',w);
    end
        
end

%% Save
savedir = [mdir filesep 'Results' filesep];
cd(savedir)
savename = ['Stroop_' num2str(ID) '.mat'];

if exist(savename,'file')==2;
    savename = ['Stroop_' num2str(ID) '_' sprintf('%s_%2.0f%02.0f',date,d(4),d(5)) '.mat'];
end

try
save([savedir savename],'Stroop');
catch
    warning('Something is amiss with this save. Retrying to save in a more general location...');
    try
        save([mdir filesep savename],'Stroop');
    catch
        warning('STILL problems saving....Try right-clicking on ''AAM'' and Save as...');
        Stroop
    end
end



%% The End!
sca
    
end
