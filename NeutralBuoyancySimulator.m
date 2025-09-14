% Neutral Buoyancy CoM-CoB Alignment Visualizer in MATLAB
% Includes pitch angle graph, buoyancy vs. suit mass chart, and diver tilting animation

function NeutralBuoyancySimulator
    % Initialize figure
    f = figure('Name', 'Neutral Buoyancy CoM-CoB Simulator', 'NumberTitle', 'off', 'WindowButtonDownFcn', @onClick);
    clf;
    t = tiledlayout(2,2,'TileSpacing','compact','Padding','compact');

    % Main visual simulation plot
    ax1 = nexttile(1,[2 1]);
    axes(ax1);
    axis equal;
    xlim([-2 2]); ylim([0 4]); hold on;
    title({'\bfNeutral Buoyancy Simulator: Drag foam (blue) or weight (black) blocks vertically', ...
           'Y-axis: Height along diver''s body (feet=0, head=3.5), X-axis: lateral shift (not used yet)'}, 'FontSize', 12);
    xlabel('X-axis (Lateral Position)', 'FontWeight','bold');
    ylabel('Y-axis (Height from Feet to Head)', 'FontWeight','bold');
    set(gca, 'FontSize', 11);

    % Diver body schematic
    rectangle('Position',[-0.3 1 0.6 2],'FaceColor',[0.85 0.85 0.85],'EdgeColor','k');
    text(-0.25, 3.05, 'Head', 'FontSize', 10);
    text(-0.25, 1.0, 'Hips', 'FontSize', 10);

    % Initial positions
    state.CoM = plot(0, 1.5, 'ko', 'MarkerSize', 10, 'DisplayName', 'Center of Mass (CoM)');
    state.CoB = plot(0, 2.5, 'bo', 'MarkerSize', 10, 'DisplayName', 'Center of Buoyancy (CoB)');

    % Foam and weight draggable blocks
    state.foam = rectangle('Position',[-0.2 2.4 0.4 0.2],'FaceColor','b','ButtonDownFcn',{@dragObject,'CoB'});
    state.weight = rectangle('Position',[-0.2 1.4 0.4 0.2],'FaceColor','k','ButtonDownFcn',{@dragObject,'CoM'});

    % Tipping arrow
    state.arrow = quiver(0, 1.5, 0, 1, 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.5);
    state.tipLabel = text(0.2, 2.0, '\leftarrow Tipping direction', 'Color', 'r', 'FontSize', 10);

    % Add slider and outputs
    state.slider = uicontrol('Style','slider','Min',0,'Max',5,'Value',1.57,'Position',[220 20 200 20], 'Callback', @updateNetForce);
    uicontrol('Style', 'text', 'Position', [20 20 200 20], 'String', 'Add Weight (kg):', 'FontWeight','bold');
    state.weightText = uicontrol('Style', 'text', 'Position', [430 20 180 20], 'String', 'Net Force: 0.00 N');
    state.offsetText = uicontrol('Style', 'text', 'Position', [620 20 180 20], 'String', 'Offset: 0.00 m');
    state.torqueText = uicontrol('Style', 'text', 'Position', [800 20 180 20], 'String', 'Torque: 0.00 Nm');

    % Pitch angle graph
    ax2 = nexttile(2);
    title('Pitch Angle vs Time', 'FontWeight','bold');
    xlabel('Time (s)', 'FontWeight','bold'); ylabel('Pitch Angle (deg)', 'FontWeight','bold');
    state.pitchData = animatedline('Parent', ax2, 'Color', 'b', 'LineWidth', 1.5);
    grid(ax2, 'on');
    state.pitchTime = 0;

    % Buoyancy vs suit mass chart
    ax3 = nexttile(4);
    title('Buoyancy vs Suit Mass', 'FontWeight','bold'); xlabel('Suit Mass (kg)', 'FontWeight','bold'); ylabel('Net Buoyant Force (N)', 'FontWeight','bold');
    suitMass = linspace(50,100,100);
    buoyancy = 922.79 - (907.43 + (suitMass - 70)*9.81);
    plot(ax3, suitMass, buoyancy, 'g', 'LineWidth', 1.5);
    grid(ax3,'on'); set(gca, 'FontSize', 11);

    % Store state
    setappdata(f, 'state', state);
    updateTippingArrow;
    updateNetForce;
    startPitchTimer(f);
end

function dragObject(src, ~, type)
    set(gcf, 'WindowButtonMotionFcn', {@onDrag, src, type});
    set(gcf, 'WindowButtonUpFcn', @onRelease);
end

function onDrag(~, ~, src, type)
    cp = get(gca, 'CurrentPoint');
    pos = get(src, 'Position');
    pos(2) = min(max(cp(1,2)-0.1, 0.5), 3.5);
    set(src, 'Position', pos);

    state = getappdata(gcf, 'state');
    if strcmp(type, 'CoB')
        set(state.CoB, 'YData', pos(2)+0.1);
    else
        set(state.CoM, 'YData', pos(2)+0.1);
    end
    updateTippingArrow;
    updateNetForce;
end

function onRelease(~, ~)
    set(gcf, 'WindowButtonMotionFcn', '');
end

function onClick(~, ~)
end

function updateTippingArrow
    state = getappdata(gcf, 'state');
    y_com = get(state.CoM, 'YData');
    y_cob = get(state.CoB, 'YData');
    dy = y_cob - y_com;
    direction = sign(dy);
    set(state.arrow, 'XData', 0, 'YData', y_com, 'UData', 0.3 * direction, 'VData', dy*0.5);
    set(state.offsetText, 'String', sprintf('Offset: %.2f m', dy));
end

function updateNetForce(~, ~)
    state = getappdata(gcf, 'state');
    mass = get(state.slider, 'Value');
    gravity = 9.81;
    net_force = (922.79 - 907.43) - mass * gravity;
    set(state.weightText, 'String', sprintf('Net Force: %.2f N', net_force));
    y_com = get(state.CoM, 'YData');
    y_cob = get(state.CoB, 'YData');
    lever_arm = y_cob - y_com;
    torque = net_force * lever_arm;
    set(state.torqueText, 'String', sprintf('Torque: %.2f Nm', torque));
end

function startPitchTimer(fig)
    t = timer('ExecutionMode', 'fixedRate', 'Period', 0.5, 'TimerFcn', @(~,~)updatePitch(fig));
    start(t);
    setappdata(fig, 'pitchTimer', t);
end

function updatePitch(fig)
    if ~isvalid(fig), return; end
    state = getappdata(fig, 'state');
    y_com = get(state.CoM, 'YData');
    y_cob = get(state.CoB, 'YData');
    pitch_angle = rad2deg(atan2((y_cob - y_com), 0.5));
    state.pitchTime = state.pitchTime + 0.5;
    addpoints(state.pitchData, state.pitchTime, pitch_angle);
end
