clear
clc

indexes = {
%         '9-companies';
    %     'DD' ;
    %     'GE' ;
    %     'AA' ;
    %     'IBM';
    %     'KO' ;
    %     'BA' ;
    %     'CAT';
    %     'DIS';
    %     'HPQ';
%         'DJIA';
%         'SP500-removed';
        'NASDAQ-removed'
    };

frame_size = 5000;
frame_step_size = 20;

save_figure = true;
save_data = true;

for i=1:length(indexes(:,1))
    path = [get_root_path(),'/financial-analysis/empirical data/',indexes{i,1},'/spectrum/window/'];
    %     data = load([indexes{i,1},'_1962_01_02__2017_07_10_ret']);
    data = load([indexes{i,1}]);
    f = figure('units','normalized','position',[.1 .1 .6 .6]);
    
    
    start_index = 1;
    end_index =frame_size;
    date_points = datetime('01-Jan-1970');
    date_start_points = datetime('01-Jan-1970');
    point_counter = 1;
    
    while end_index < length(data.returns)
        
        spectrum_file_name = [indexes{i,1},'-spectrum-',datestr(data.date(start_index),'yyyy-mm-dd'),...
            '-',datestr(data.date(end_index),'yyyy-mm-dd')];
        
        spectrum_data = load([path,spectrum_file_name]);
        
        alpha_y(point_counter) = spectrum_width(spectrum_data.MFDFA2.alfa(31:70),spectrum_data.MFDFA2.f(31:70));
        alpha_y_l(point_counter) = spectrum_width(spectrum_data.MFDFA2.alfa(31:50),spectrum_data.MFDFA2.f(31:50));
        alpha_y_r(point_counter) = spectrum_width(spectrum_data.MFDFA2.alfa(51:70),spectrum_data.MFDFA2.f(51:70));
        date_points(point_counter) = data.date(end_index);
        date_start_points(point_counter) = data.date(start_index);
        start_index = start_index + frame_step_size;
        end_index = end_index + frame_step_size;
        point_counter =point_counter+1;
        
    end
    
    plot(datenum(date_points),alpha_y,'xk','MarkerSize',8, 'DisplayName',indexes{i,1});
    hold on;
    plot(datenum(date_points),alpha_y_l,'ob','MarkerSize',8, 'DisplayName',[indexes{i,1},'- right wing']);
    plot(datenum(date_points),alpha_y_r,'<r','MarkerSize',8, 'DisplayName',[indexes{i,1},'- left wing']);
    hold on;
    
    legend show;
    datetick('x','yyyy');
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'fontsize',14);
    hold off;
    ylabel('\Delta{\alpha} (t)','FontSize', 14);
    xlabel('t [year]','FontSize', 14);
    ylim([0 0.7]);
    xlim([datenum(date_points(1)) datenum(date_points(end))]);
    
    if save_figure == true
        savefig(f,[indexes{i,1},'-spectrum-width-by-wing']);
    end
    
    if save_data ==true
        fid = fopen([indexes{i},'-spectrum-width-by-wing.csv'], 'w') ;
        fprintf(fid,['window_start_date,','window_end_date,','total-width,','left-wing,','right-wing\n']);
        
        for j=1:1:length(date_points)
            fprintf(fid,[datestr(date_start_points(j),'dd-mm-yyyy'),',',datestr(date_points(j),'dd-mm-yyyy'),',',num2str(alpha_y(j)),',',num2str(alpha_y_l(j)),',',num2str(alpha_y_r(j)),'\n']);
        end
        fclose(fid);
        
    end
    
end


